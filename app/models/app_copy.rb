# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
require 'fileutils'
require "open3"

class AppCopy < ActiveRecord::Base
  extend IoUtils
  extend DataUtils
  include TimeUtils
  belongs_to :application
  has_many :app_copy_logs

  scope :daily, where(daily: true)

  def average_runtime
    self.app_copy_logs.average(:runtime)
  end

  def last_runtime
    self.app_copy_logs.last.runtime
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

    # check for maintenance mode
    if(!development_location.check_maintenance)
      if(announce)
        self.no_maintenance_notification(coder)
      end
      return {success: false, error: "Development application is not in maintenance mode."}
    end


    if(announce)
      self.start_notification(coder)
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
      self.completed_notification(copy_log)
    end
    copy_log
  end

  def database_copy(production_location,development_location,debug)
    if(development_location.dbname =~ %r{prod})
      return {success: false, error: "Incorrect database target"}
    end

    target_copy_file = "#{Settings.data_dump_dir_dump}/copy_#{production_location.dbname}.sql"

    result = self.class.dump_database_to_file(production_location.dbname,'production_replica',target_copy_file,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end


    # import
    result = self.class.import_database_from_file(development_location.dbname,'development',target_copy_file,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    # wordpress transformation
    if(self.is_wordpress?)
      result = self.class.wp_srdb_database(development_location.dbname,'development',production_location.host,development_location.host,debug)
      # ignore result
    end

    size = File.size(target_copy_file)
    # delete
    File.delete(target_copy_file)

    {success: true, copy_size: size}
  end


  def start_notification(coder = Coder.coderbot)
      time_period_string_last = time_period_to_s(self.last_runtime)
      time_period_string_avg = time_period_to_s(self.average_runtime)

      attachment = { "fallback" => "#{coder.name} has started a production :arrow_right: development database copy for #{self.application.name}. This last took #{time_period_string_last}.",
      "text" => "#{self.application.name.capitalize} production :arrow_right: development database copy started",
      "fields" => [
        {
          "title" => "Who",
          "value" => "#{coder.name}",
          "short" => true
        },
        {
          "title" => "Last Runtime",
          "value" =>  "#{time_period_string_last} (Average: #{time_period_string_avg})",
          "short" =>  true
        }
      ],
      "color" => "meh"
    }

    SlackNotification.post({attachment: attachment, channel: "#deploys", username: "Engineering Database Tools Notification"})
  end

  def request_notification(coder = Coder.coderbot)
    time_period_string_last = time_period_to_s(self.last_runtime)
    time_period_string_avg = time_period_to_s(self.average_runtime)

      attachment = { "fallback" => "#{coder.name} has requested a production :arrow_right: development database copy for #{self.application.name}. Waiting 60 seconds so that the development application can be put into maintenance mode.",
      "text" => "#{self.application.name.capitalize} production :arrow_right: development database copy requested. Waiting 60 seconds so that the development application can be put into maintenance mode.",
      "fields" => [
        {
          "title" => "Who",
          "value" => "#{coder.name}",
          "short" => true
        }
      ],
      "color" => "meh"
    }

    SlackNotification.post({attachment: attachment, channel: "#deploys", username: "Engineering Database Tools Notification"})
  end

  def no_maintenance_notification(coder = Coder.coderbot)

    attachment = { "fallback" => "The production :arrow_right: development database copy for #{self.application.name} has been canceled!. The development application is not in maintenance mode",
    "text" => ":rotating_light: #{self.application.name.capitalize} production :arrow_right: development database copy canceled! :rotating_light: ",
    "fields" => [],
    "color" => "danger"
  }

  attachment["fields"].push({"title" => "Reason", "value" => "The development application is not in maintenance mode. #{coder.name} please place the application in maintenance mode.", "short" => false})

    SlackNotification.post({attachment: attachment, channel: "#deploys", username: "Engineering Database Tools Notification"})
  end


  def completed_notification(copy_log)
    if(copy_log.success?)
      copy_log._success_notification
    else
      copy_log._failure_notification
    end
  end

end
