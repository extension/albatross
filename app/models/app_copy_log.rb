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

  def self.copy_notification(copy_log)
    if(copy_log.success?)
      message = ":checkered_flag: The production => development database copy for #{copy_log.application.name} is complete (dump file size: #{AppCopy.humanize_bytes(copy_log.size)})."
    else
      message = ":warning: The production => development database copy for #{copy_log.application.name} has FAILED!. Details: #{copy_log.additionaldata[:error]}"
    end
    delay.speak(message)
  end


    def _success_notification

      attachment = { "fallback" => "The production :arrow_right: development database copy for #{self.application.name} is complete (size: #{AppCopy.humanize_bytes(self.size)}.",
      "text" => "#{self.application.name.capitalize} production :arrow_right: development database copy complete",
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

    SlackNotification.post({attachment: attachment, channel: "#testing", username: "Engineering Database Tools Notification"})
  end

  def _failure_notification

      attachment = { "fallback" => "The production :arrow_right: development database copy for #{self.application.name} has FAILED!. Details: #{self.additionaldata[:error]}",
      "text" => ":rotating_light: #{self.application.name.capitalize} production :arrow_right: development database copy FAILED! :rotating_light:",
      "fields" => [],
      "color" => "danger"
    }

    if(!self.additionaldata[:error].blank?)
      attachment["fields"].push({"title" => "Details", "value" => self.additionaldata[:error], "short" => false})
    else
      attachment["fields"].push({"title" => "Details", "value" => "No details available", "short" => false})
    end

    SlackNotification.post({attachment: attachment, channel: "#testing", username: "Engineering Database Tools Notification"})
  end

end
