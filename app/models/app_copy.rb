# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
require 'fileutils'
require "open3"

class AppCopy < ActiveRecord::Base
  extend DataUtils
  belongs_to :application
  has_many :app_copy_logs

  scope :daily, where(daily: true)

  def average_runtime
    self.app_copy_logs.average(:runtime)
  end

  def mark_in_progress
    self.update_attribute(:in_progress,true)
  end

  def mark_complete
    self.update_attribute(:in_progress,false)
  end

  def copy(options = {})
    coder = options[:coder] 
    debug = (options[:debug].present? ? options[:debug] : false)
    announce = (options[:announce].present? ? options[:announce] : false)

    # bail if the backup dir doesn't exist
    if(!File.exists?(Settings.data_dump_dir_dump))
      return {success: false, error: "#{Settings.data_dump_dir_dump} does not exist"}
    end

    if(self.in_progress?)
      return {success: false, error: "Copy already in progress"}
    end

    production_location = self.application.app_location_for_location(AppLocation::PRODUCTION)
    if(!production_location or !production_location.dbname.present?)
      return {success: false, error: "No production database for this application."}
    end


    development_location = self.application.app_location_for_location(AppLocation::DEVELOPMENT)
    if(!development_location or !development_location.dbname.present?)
      return {success: false, error: "No development database for this application."}
    end


    if(announce)
      Campout.copy_notification_start(self,coder)
    end

    self.mark_in_progress
    started = Time.now
    result = database_copy(production_location,development_location,debug)
    finished = Time.now
    self.mark_complete
    if(result[:success])
      size = result[:copy_size]
      self.update_attributes(last_copy_at: Time.now, last_copy_size: size)
    end
    copy_log = self.app_copy_logs.create(started_at: started, finished_at: finished, runtime: finished - started, success: result[:success], additionaldata: result, size: size, coder: coder)

    if(announce)
      Campout.copy_notification(copy_log)
    end
    copy_log
  end

  def database_copy(production_location,development_location,debug)
    if(development_location.dbname =~ %r{prod})
      return {success: false, error: "Incorrect database target"}
    end

    target_copy_file = "#{Settings.data_dump_dir_dump}/copy_#{production_location.dbname}.sql"

    result = self.class.dump_database_to_file(production_location.dbname,target_copy_file,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end


    # import
    result = self.class.import_database_to_master_server_from_file(development_location.dbname,target_copy_file,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    size = File.size(target_copy_file)
    # delete
    File.delete(target_copy_file)

    {success: true, copy_size: size}
  end

end

