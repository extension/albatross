# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
require 'fileutils'

class AppCopyLog < ActiveRecord::Base
  include TimeUtils
  serialize :additionaldata
  belongs_to :coder
  belongs_to :app_copy
  has_one :application, through: :app_copy

    def _success_notification

      post_options = {}
      post_options[:channel] = Settings.deploys_slack_channel
      post_options[:username] = "Engineering Database Copy Notification"
      post_options[:icon_emoji] = ':floppy_disk:'

      attachment = { "fallback" => "The production :arrow_right: staging database copy for #{self.application.name} is complete (size: #{AppCopy.humanize_bytes(self.size)}.",
      "text" => "#{self.application.name.capitalize} production :arrow_right: staging database copy complete",
      "fields" => [
        {
          "title" => "Who",
          "value" => "#{self.coder.name}",
          "short" => true
        },
        {
          "title" => "Size",
          "value" =>  "#{AppCopy.humanize_bytes(self.size)}",
          "short" =>  true
        },
        {
          "title" => "Time",
          "value" =>  "#{time_period_to_s(self.runtime)} (Average: #{time_period_to_s(self.app_copy.average_runtime)})",
          "short" =>  true
        }
      ],
      "color" => "good"
    }

    post_options[:attachment] = attachment


    SlackNotification.post(post_options)
  end

  def _failure_notification
    post_options = {}
    post_options[:channel] = Settings.deploys_slack_channel
    post_options[:username] = "Engineering Database Copy Notification"
    post_options[:icon_emoji] = ':floppy_disk:'

      attachment = { "fallback" => "The production :arrow_right: staging database copy for #{self.application.name} has FAILED!. Details: #{self.additionaldata[:error]}",
      "text" => ":rotating_light: #{self.application.name.capitalize} production :arrow_right: staging database copy FAILED! :rotating_light:",
      "fields" => [],
      "color" => "danger"
    }

    if(!self.additionaldata[:error].blank?)
      attachment["fields"].push({"title" => "Details", "value" => self.additionaldata[:error], "short" => false})
    else
      attachment["fields"].push({"title" => "Details", "value" => "No details available", "short" => false})
    end

    post_options[:attachment] = attachment

    SlackNotification.post(post_options)
  end

end
