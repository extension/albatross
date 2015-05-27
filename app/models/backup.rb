# === COPYRIGHT:
# Copyright (c) North Carolina State University
# === LICENSE:
# see LICENSE file

class Backup < ActiveRecord::Base
  include TimeUtils
  include Rails.application.routes.url_helpers
  default_url_options[:host] = Settings.urlwriter_host


  attr_accessible :monitored_server, :monitored_server_id, :backupcommand, :server_name, :server_fqdn, :start, :finish, :runtime, :success, :stdout, :stderr


  belongs_to :monitored_server

  before_save :set_runtime
  before_save :set_server
  after_create :post_slack_notification

  def self.save_log(provided_params)
    create_options = {}
    create_options[:start]   = provided_params[:start]
    create_options[:finish]   = provided_params[:finish]
    if(provided_params[:runtime] and provided_params[:runtime].to_f > 0)
      create_options[:runtime] = provided_params[:runtime].to_f
    end
    create_options[:success]   = provided_params[:success]
    create_options[:stdout] = provided_params[:stdout]
    create_options[:stderr] = provided_params[:stderr]
    create_options[:server_name] = provided_params[:server_name]
    create_options[:server_fqdn] = provided_params[:server_fqdn]
    create_options[:backupcommand] = provided_params[:backupcommand]

    if(backup_log = self.create(create_options))
      backup_log.monitored_server.touch(:last_backup_at) if backup_log.monitored_server
      backup_log
    else
      nil
    end
  end


  def set_runtime
    if(!self.finish.blank? and !self.start.blank? and self.runtime.blank?)
      self.runtime = self.finish - self.start
    end
  end

  def set_server
    if(monitored_server = MonitoredServer.where(name: self.server_name).first)
      self.monitored_server_id = monitored_server.id
    end
  end

  def post_slack_notification
    if(!self.success?)
      self.error_notification
    else
      self.success_notification
    end
  end

  def log_url
    backup_url(self.id)
  end

  def error_notification
      post_options = {}
      post_options[:channel] = Settings.systems_slack_channel
      post_options[:username] = "Backup Error Notification"
      post_options[:icon_emoji] = ':vhs:'

      attachment = { "fallback" => ":rotating_light:  #{self.server_name} backup error! Details #{self.log_url} :rotating_light:",
      "text" => ":rotating_light: #{self.server_name} backup error! :rotating_light:",
      "fields" => [
        {
          "title" => "Server",
          "value" => "#{self.server_name}",
          "short" => false
        },
      ],
      "color" => "danger"
    }

    attachment["fields"].push({"title" => "Details", "value" => self.log_url, "short" => false})
    post_options[:attachment] = attachment
    SlackNotification.post(post_options)
  end

  def success_notification
      post_options = {}
      post_options[:channel] = Settings.systems_slack_channel
      post_options[:username] = "Backup Success Notification"
      post_options[:icon_emoji] = ':vhs:'

      attachment = { "fallback" => ":stars: #{self.server_name} backup success! Details #{self.log_url}",
      "text" => ":stars: #{self.server_name} backup sucess!",
      "fields" => [
        {
          "title" => "Server",
          "value" => "#{self.server_name}",
          "short" => true
        },
        {
          "title" => "Runtime",
          "value" =>  "#{self.runtime_to_s}",
          "short" =>  true
        }
      ],
      "color" => "good"
    }

    attachment["fields"].push({"title" => "Details", "value" => self.log_url, "short" => false})
    post_options[:attachment] = attachment
    SlackNotification.post(post_options)
  end



  def runtime_to_s
    self.time_period_to_s(self.runtime)
  end

end
