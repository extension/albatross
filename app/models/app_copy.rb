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
    if(last_copy = self.app_copy_logs.last)
      self.app_copy_logs.last.runtime
    else
      0
    end
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

    staging_location = self.application.app_location_for_location(AppLocation::STAGING)
    if(!staging_location or !staging_location.dbname.present?)
      return {success: false, error: "No staging database for this application."}
    end

    # check for maintenance mode
    if(!staging_location.check_maintenance)
      if(announce)
        self.no_maintenance_notification(coder)
      end
      return {success: false, error: "Staging application is not in maintenance mode."}
    end


    if(announce)
      self.start_notification(coder)
    end

    self.mark_in_progress
    started = Time.now
    result = database_copy(production_location,staging_location,debug)
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

  def database_copy(production_location,staging_location,debug)
    if(staging_location.dbname =~ %r{prod})
      return {success: false, error: "Incorrect database target"}
    end

    target_copy_file = "#{Settings.data_dump_dir_dump}/copy_#{production_location.dbname}.sql"

    result = self.class.dump_database_to_file(production_location.dbname,'production_replica',target_copy_file,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    # concatenate cache tables?
    if(self.is_drupal?)
      command = "/bin/cat #{Rails.root}/db/drupal_cache_tables.sql >> #{target_copy_file}"
      result = self.class.run_command(command)
      if(!result.blank?)
        return {success: false, error: "#{result}"}
      end
    end

    # drop tables
    self.class.drop_tables_from_staging_database(staging_location.dbname)

    # import
    result = self.class.import_database_from_file(staging_location.dbname,'staging',target_copy_file,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end
    # wordpress transformation
    if(self.is_wordpress?)
      search_regex = "'~(https?:\\/\\/)#{Regexp.escape(production_location.display_url)}~'"
      regplace_regex = "'$1#{staging_location.display_url}'"
      result = self.class.wp_srdb_database(staging_location.dbname,'staging',search_regex,regplace_regex,true,debug)

      search_regex = "'~^#{Regexp.escape(production_location.display_url)}~'"
      regplace_regex = "'#{staging_location.display_url}'"
      result = self.class.wp_srdb_database(staging_location.dbname,'staging',search_regex,regplace_regex,true,debug)
    end

    size = File.size(target_copy_file)
    # delete
    File.delete(target_copy_file)

    {success: true, copy_size: size}
  end


  def start_notification(coder = Coder.coderbot)

    post_options = {}
    post_options[:channel] = Settings.deploys_slack_channel
    post_options[:username] = "Engineering Database Copy Notification"
    post_options[:icon_emoji] = ':floppy_disk:'

      time_period_string_last = time_period_to_s(self.last_runtime)
      time_period_string_avg = time_period_to_s(self.average_runtime)

      attachment = { "fallback" => "#{coder.name} has started a production :arrow_right: staging database copy for #{self.application.name}. This last took #{time_period_string_last}.",
      "text" => "#{self.application.name.capitalize} production :arrow_right: staging database copy started",
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

    post_options[:attachment] = attachment


    SlackNotification.post(post_options)
  end

  def request_notification(coder = Coder.coderbot)
    post_options = {}
    post_options[:channel] = Settings.deploys_slack_channel
    post_options[:username] = "Engineering Database Copy Notification"
    post_options[:icon_emoji] = ':floppy_disk:'

    time_period_string_last = time_period_to_s(self.last_runtime)
    time_period_string_avg = time_period_to_s(self.average_runtime)

      attachment = { "fallback" => "#{coder.name} has requested a production :arrow_right: staging database copy for #{self.application.name}. Waiting 60 seconds so that the staging application can be put into maintenance mode.",
      "text" => "#{self.application.name.capitalize} production :arrow_right: staging database copy requested. Waiting 60 seconds so that the staging application can be put into maintenance mode.",
      "fields" => [
        {
          "title" => "Who",
          "value" => "#{coder.name}",
          "short" => true
        }
      ],
      "color" => "meh"
    }

    post_options[:attachment] = attachment


    SlackNotification.post(post_options)
  end

  def no_maintenance_notification(coder = Coder.coderbot)

    post_options = {}
    post_options[:channel] = Settings.deploys_slack_channel
    post_options[:username] = "Engineering Database Copy Notification"
    post_options[:icon_emoji] = ':no_entry_sign:'

    attachment = { "fallback" => "The production :arrow_right: staging database copy for #{self.application.name} has been canceled!. The development application is not in maintenance mode",
    "text" => ":rotating_light: #{self.application.name.capitalize} production :arrow_right: staging database copy canceled! :rotating_light: ",
    "fields" => [],
    "color" => "danger"
    }

    attachment["fields"].push({"title" => "Reason", "value" => "The staging application is not in maintenance mode. #{coder.name} please place the application in maintenance mode.", "short" => false})

    post_options[:attachment] = attachment

    SlackNotification.post(post_options)
  end


  def completed_notification(copy_log)
    if(copy_log.success?)
      copy_log._success_notification
    else
      copy_log._failure_notification
    end
  end

end
