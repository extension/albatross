# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
require 'fileutils'
require "open3"

class AppDump < ActiveRecord::Base
  extend IoUtils
  extend DataUtils
  serialize :scrubbers

  attr_accessible :application, :application_id, :app_location, :app_location_id, :dbtype, :dbname, :daily, :scrub, :scrubbers, :in_progress, :last_dumped_at, :last_dump_size


  belongs_to :application
  belongs_to :app_location

  has_many :app_dump_logs

  scope :production, where(dbtype: 'production')
  scope :daily, where(daily: true)
  scope :nonsnapshot, where(is_snapshot: false)


  def average_runtime
    self.app_dump_logs.average(:runtime)
  end

  def localdev_host
    "#{self.application.name.downcase}.localdev:#{Settings.data_dump_localdev_port}"
  end

  def dumpinfo
    if(self.is_snapshot?)
      dumpfile = "#{Settings.data_dump_dir_dump}/snapshots/#{self.dbname}"
    elsif(self.scrub?)
      dumpfile = "#{Settings.data_dump_dir_dump}/#{self.dbname}_scrubbed.sql.gz"
    elsif(self.is_wordpress?)
      dumpfile = "#{Settings.data_dump_dir_dump}/#{self.dbname}_localdev.sql.gz"
    else
      dumpfile = "#{Settings.data_dump_dir_dump}/#{self.dbname}.sql.gz"
    end

    if(self.in_progress?)
      return {'success' => false, 'error' => "dump currently in progress"}
    end

    return {'success' => true, 'file' => dumpfile, 'server' => 'engineering.extension.org', 'size' => self.last_dump_size, 'last_dumped_at' => self.last_dumped_at, 'dbtype' => self.dbtype}
  end

  def mark_in_progress
    self.update_attribute(:in_progress,true)
  end

  def mark_complete
    self.update_attribute(:in_progress,false)
  end

  def dump(options = {})
    coder = options[:coder] || Coder.coderbot
    debug = (options[:debug].present? ? options[:debug] : false)
    announce = (options[:announce].present? ? options[:announce] : false)

    # bail if the backup dir doesn't exist
    if(!File.exists?(Settings.data_dump_dir_dump))
      return {success: false, error: "#{Settings.data_dump_dir_dump} does not exist"}
    end

    if(self.in_progress?)
      return {success: false, error: "Dump already in progress"}
    end

    if(announce)
      SlackNotification.dump_notification_start(self,coder)
    end

    self.mark_in_progress
    started = Time.now
    if(self.scrub?)
      result = scrubbed_dump(debug)
    elsif(self.is_wordpress?)
      result = wordpress_dump(debug)
    else
      result = normal_dump(debug)
    end
    finished = Time.now
    self.mark_complete
    if(result[:success])
      size = File.size(result[:file])
      self.update_attributes(last_dumped_at: Time.now, last_dump_size: size)
    end
    dump_log = self.app_dump_logs.create(started_at: started, finished_at: finished, runtime: finished - started, success: result[:success], additionaldata: result, size: size, coder: coder)

    if(announce)
      SlackNotification.dump_notification(dump_log)
    end
    dump_log
  end

  def normal_dump(debug = false)

    target_file = "#{Settings.data_dump_dir_dump}/#{self.dbname}.sql"
    tmp_dump_file =  "#{target_file}.tmp"

    if(self.dbtype == 'development')
      fromhost = 'development'
    elsif(self.dbtype == 'production')
      fromhost = 'production_replica'
    else
      # bail
      return {success: false, file: "n/a", dump_size: 0}
    end


    result = self.class.dump_database_to_file(self.dbname,fromhost,tmp_dump_file,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end


    # size it up
    dump_size = File.size(tmp_dump_file)

    # compress it
    gzip_command = "#{Settings.data_dump_gzip_cmd} #{tmp_dump_file}"
    result = self.class.run_command(gzip_command,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    # move it
    move_source = "#{tmp_dump_file}.gz"
    move_target = "#{target_file}.gz"

    begin
      FileUtils.mv(move_source,move_target,force: true)
    rescue Exception => e
      return {success: false, error: e}
    end
    {success: true, file: "#{target_file}.gz", dump_size: dump_size}
  end

  def scrubbed_dump(debug = false)
    target_file = "#{Settings.data_dump_dir_dump}/#{self.dbname}_scrubbed.sql"
    tmp_dump_file =  "#{target_file}.tmp"
    pre_scrubbed_file = "#{Settings.data_dump_dir_dump}/#{self.dbname}.sql.pre_scrubbed"
    scrubbed_database = "scrubbed_#{self.dbname}"

    if(self.dbtype == 'development')
      fromhost = 'development'
    elsif(self.dbtype == 'production')
      fromhost = 'production_replica'
    else
      # bail
      return {success: false, file: "n/a", dump_size: 0}
    end

    # dump
    result = self.class.dump_database_to_file(self.dbname,fromhost,pre_scrubbed_file,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    # drop
    result = self.class.drop_scrubbed_database(scrubbed_database,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    result = self.class.create_scrubbed_database(scrubbed_database,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    # import
    result = self.class.import_database_from_file(scrubbed_database,'scrubbed',pre_scrubbed_file,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    # unlink
    File.delete(pre_scrubbed_file)

    # scrub
    self.class.scrub_database(scrubbed_database,self.scrubbers,debug)

    # dump
    result = self.class.dump_database_to_file(scrubbed_database,'scrubbed',tmp_dump_file,debug)

    # size it up
    dump_size = File.size(tmp_dump_file)

    # compress it
    gzip_command = "#{Settings.data_dump_gzip_cmd} #{tmp_dump_file}"
    result = self.class.run_command(gzip_command,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    # move it
    move_source = "#{tmp_dump_file}.gz"
    move_target = "#{target_file}.gz"

    begin
      FileUtils.mv(move_source,move_target,force: true)
    rescue Exception => e
      return {success: false, error: e}
    end

    # drop
    self.class.drop_scrubbed_database(scrubbed_database,debug)

    {success: true, file: "#{target_file}.gz", dump_size: dump_size}

  end

  def wordpress_dump(debug = false)
    target_file = "#{Settings.data_dump_dir_dump}/#{self.dbname}_localdev.sql"
    tmp_dump_file =  "#{target_file}.tmp"
    pre_scrubbed_file = "#{Settings.data_dump_dir_dump}/#{self.dbname}.sql.pre_scrubbed"
    scrubbed_database = "localdev_#{self.dbname}"

    if(self.dbtype == 'development')
      fromhost = 'development'
    elsif(self.dbtype == 'production')
      fromhost = 'production_replica'
    else
      # bail
      return {success: false, file: "n/a", dump_size: 0}
    end

    # dump
    result = self.class.dump_database_to_file(self.dbname,fromhost,pre_scrubbed_file,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    # drop
    result = self.class.drop_scrubbed_database(scrubbed_database,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    result = self.class.create_scrubbed_database(scrubbed_database,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    # import
    result = self.class.import_database_from_file(scrubbed_database,'scrubbed',pre_scrubbed_file,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    # unlink
    File.delete(pre_scrubbed_file)

    # search and replace
    search_host = self.app_location.host
    replace_host = self.localdev_host
    result = self.class.wp_srdb_database(scrubbed_database,'scrubbed',search_host,replace_host,debug)
    # ignore result

    # dump
    result = self.class.dump_database_to_file(scrubbed_database,'scrubbed',tmp_dump_file,debug)

    # size it up
    dump_size = File.size(tmp_dump_file)

    # compress it
    gzip_command = "#{Settings.data_dump_gzip_cmd} #{tmp_dump_file}"
    result = self.class.run_command(gzip_command,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    # move it
    move_source = "#{tmp_dump_file}.gz"
    move_target = "#{target_file}.gz"

    begin
      FileUtils.mv(move_source,move_target,force: true)
    rescue Exception => e
      return {success: false, error: e}
    end

    # drop
    self.class.drop_scrubbed_database(scrubbed_database,debug)

    {success: true, file: "#{target_file}.gz", dump_size: dump_size}

  end



end
