# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
require 'fileutils'
require "open3"

class AppDump < ActiveRecord::Base
  serialize :scrubbers
  belongs_to :application
  has_many :app_dump_logs

  scope :production, where(dbtype: 'production')
  scope :daily, where(daily: true)

  def dumpinfo
    if(self.scrub?)
      dumpfile = "#{Settings.data_dump_dir_dump}/#{self.dbname}_scrubbed.sql.gz"
    else
      dumpfile = "#{Settings.data_dump_dir_dump}/#{self.dbname}.sql.gz"
    end

    if(self.in_progress?)
      return {'success' => false, 'error' => "dump currently in progress"}
    end

    return {'success' => true, 'file' => dumpfile, 'server' => 'data.engineering.extension.org', 'size' => self.last_dump_size, 'last_dumped_at' => self.last_dumped_at, 'dbtype' => self.dbtype}
  end

  def mark_in_progress
    self.update_attribute(:in_progress,true)
  end

  def mark_complete
    self.update_attribute(:in_progress,false)
  end


  def dump(debug=false)
    # bail if the backup dir doesn't exist
    if(!File.exists?(Settings.data_dump_dir_dump))
      return {success: false, error: "#{Settings.data_dump_dir_dump} does not exist"}
    end

    if(self.in_progress?)
      return {success: false, error: "Dump already in progress"}
    end

    self.mark_in_progress
    started = Time.now
    if(self.scrub?)
      result = scrubbed_dump(debug)
    else
      result = normal_dump(debug)
    end
    finished = Time.now
    self.mark_complete
    if(result[:success])
      size = File.size(result[:file])
      self.update_attributes(last_dumped_at: Time.now, last_dump_size: size)
    end
    self.app_dump_logs.create(started_at: started, finished_at: finished, runtime: finished - started, success: result[:success], additionaldata: result, size: size)
    result
  end

  def normal_dump(debug = false)

    target_file = "#{Settings.data_dump_dir_dump}/#{self.dbname}.sql"
    tmp_dump_file =  "#{target_file}.tmp"

    result = self.class.dump_database_to_file(self.dbname,tmp_dump_file,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

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
    {success: true, file: "#{target_file}.gz"}
  end

  def scrubbed_dump(debug = false)
    target_file = "#{Settings.data_dump_dir_dump}/#{self.dbname}_scrubbed.sql"
    tmp_dump_file =  "#{target_file}.tmp"
    pre_scrubbed_file = "#{Settings.data_dump_dir_dump}/#{self.dbname}.sql.pre_scrubbed"
    scrubbed_database = "scrubbed_#{self.dbname}"

    # dump
    result = self.class.dump_database_to_file(self.dbname,pre_scrubbed_file,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    # drop
    result = self.class.drop_database(scrubbed_database,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    result = self.class.create_database(scrubbed_database,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    # import
    result = self.class.import_database_from_file(scrubbed_database,pre_scrubbed_file,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    # unlink
    File.delete(pre_scrubbed_file)

    # scrub
    self.class.scrub_database(scrubbed_database,self.scrubbers,debug)

    # dump
    result = self.class.dump_database_to_file(scrubbed_database,tmp_dump_file,debug)

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
    self.class.drop_database(scrubbed_database,debug)

    {success: true, file: "#{target_file}.gz"}

  end

  def self.dump_database_to_file(database, outputfile, debug=false)
    command_array = []
    command_array << "#{Settings.data_dump_mysql_dump_cmd}"
    command_array << "--user=#{Settings.data_dump_mysql_user}"
    command_array << "--password=#{Settings.data_dump_mysql_pass}"
    command_array << "--socket=#{Settings.data_dump_mysql_socket}"
    command_array << "--extended-insert"
    command_array << "--no-autocommit"
    command_array << "#{database}"
    command_array << "> #{outputfile}"
    command = command_array.join(' ')
    run_command(command,debug)
  end

  def self.drop_database(database, debug=false)
    if(database =~ %r{^scrubbed})
      command_array = []
      command_array << "#{Settings.data_dump_mysql_cmd}"
      command_array << "--user=#{Settings.data_dump_mysql_user}"
      command_array << "--password=#{Settings.data_dump_mysql_pass}"
      command_array << "--socket=#{Settings.data_dump_mysql_socket}"
      command_array << "-e \"DROP DATABASE IF EXISTS #{database}\""
      command = command_array.join(' ')
      run_command(command,debug)
    end
  end

  def self.create_database(database, debug=false)
    if(database =~ %r{^scrubbed})
      command_array = []
      command_array << "#{Settings.data_dump_mysql_cmd}"
      command_array << "--user=#{Settings.data_dump_mysql_user}"
      command_array << "--password=#{Settings.data_dump_mysql_pass}"
      command_array << "--socket=#{Settings.data_dump_mysql_socket}"
      command_array << "-e \"CREATE DATABASE IF NOT EXISTS #{database}\""
      command = command_array.join(' ')
      run_command(command,debug)
    end
  end

  def self.import_database_from_file(database,inputfile, debug=false)
    command_array = []
    command_array << "#{Settings.data_dump_mysql_cmd}"
    command_array << "--user=#{Settings.data_dump_mysql_user}"
    command_array << "--password=#{Settings.data_dump_mysql_pass}"
    command_array << "--socket=#{Settings.data_dump_mysql_socket}"
    command_array << "#{database}"
    command_array << "< #{inputfile}"
    command = command_array.join(' ')
    run_command(command,debug)
  end

  def self.scrub_database(database,scrubbers,debug)
    base_command_array = []
    base_command_array << "#{Settings.data_dump_mysql_cmd}"
    base_command_array << "--user=#{Settings.data_dump_mysql_user}"
    base_command_array << "--password=#{Settings.data_dump_mysql_pass}"
    base_command_array << "--socket=#{Settings.data_dump_mysql_socket}"
    base_command_array << "--database=#{database}"
    base_command = base_command_array.join(' ')

    scrubbers.keys.each do |table|
      column = scrubbers[table]['column']
      value = scrubbers[table]['value']
      scrub_query = "\"UPDATE #{table} SET #{column}='#{value}';\""
      command = "#{base_command} -e #{scrub_query}"
      run_command(command,debug)
    end
  end


  def self.run_command(command,debug = false)
    logger.debug "running #{command}" if debug
    stdin, stdout, stderr = Open3.popen3(command)
    results = stdout.readlines + stderr.readlines
    return results.join('')
  end

  def self.capture_stderr &block
    real_stderr, $stderr = $stderr, StringIO.new
    yield
    $stderr.string
  ensure
    $stderr = real_stderr
  end

  # code from: https://github.com/ripienaar/mysql-dump-split
  def self.humanize_bytes(bytes)
    if(bytes != 0)
      units = %w{B KB MB GB TB}
      e = (Math.log(bytes)/Math.log(1024)).floor
      s = "%.1f"%(bytes.to_f/1024**e)
      s.sub(/\.?0*$/,units[e])
    end
  end

end
