# === COPYRIGHT:
# Copyright (c) North Carolina State University
# === LICENSE:
# see LICENSE file

class CronmonLog < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  default_url_options[:host] = Settings.urlwriter_host

  belongs_to :cronmon
  has_one :cronmon_log_output, :dependent => :destroy
  accepts_nested_attributes_for :cronmon_log_output

  before_save :set_runtime
  after_create :notify_if_error

  def set_runtime
    if(!self.finish.blank? and !self.start.blank? and self.runtime.blank?)
      self.runtime = self.finish - self.start
    end
  end

  def stdout
    self.cronmon_log_output.stdout
  end

  def stderr
    self.cronmon_log_output.stderr
  end

  def notify_if_error(force = false)
    if(force or !self.success?)
      Notification.create(notifiable: self, notification_type: Notification::CRONMON_ERROR)
      self.error_notification
    end
  end

  def log_url
    showlog_cronmon_url(self.cronmon,log_id: self.id)
  end

  def error_notification
      post_options = {}
      post_options[:channel] = Settings.systems_slack_channel
      post_options[:username] = "Cronmon Notification"
      post_options[:icon_emoji] = ':clock5:'

      attachment = { "fallback" => "rotating_light:  #{self.cronmon.label} execution error! Details #{self.log_url} rotating_light:",
      "text" => ":rotating_light: #{self.cronmon.label} execution error! :rotating_light:",
      "fields" => [
        {
          "title" => "Server",
          "value" => "#{self.cronmon.monitored_server.name}",
          "short" => false
        },
        {
          "title" => "Command",
          "value" =>  "#{self.command}",
          "short" =>  false
        }
      ],
      "color" => "danger"
    }

    attachment["fields"].push({"title" => "Details", "value" => self.log_url, "short" => false})
    post_options[:attachment] = attachment

    SlackNotification.post(post_options)

  end

end
