# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
require 'fileutils'

class AppDumpLog < ActiveRecord::Base
  include TimeUtils
  serialize :additionaldata
  belongs_to :coder
  belongs_to :app_dump
  has_one :application, through: :app_dump


  def _success_notification

      attachment = { "fallback" => "The #{self.app_dump.dbtype} database for #{self.application.name} has been dumped (compressed size: #{AppDump.humanize_bytes(self.size)}.",
      "text" => "#{self.application.name.capitalize} #{self.app_dump.dbtype} dump complete",
      "fields" => [
        {
          "title" => "Who",
          "value" => "#{self.coder.name}",
          "short" => true
        },
        {
          "title" => "Compressed Size",
          "value" =>  "#{AppDump.humanize_bytes(self.size)}",
          "short" =>  true
        },
        {
          "title" => "Time",
          "value" =>  "#{time_period_to_s(self.runtime)} (Average: #{time_period_to_s(self.app_dump.average_runtime)})",
          "short" =>  true
        }
      ],
      "color" => "good"
    }

    SlackNotification.post({attachment: attachment, channel: "#deploys", username: "Engineering Database Tools Notification"})
  end

  def _failure_notification

    attachment = { "fallback" => "The #{self.app_dump.dbtype} database dump for #{self.application.name} has FAILED!. Details: #{self.additionaldata[:error]}",
    "text" => ":rotating_light: #{self.application.name.capitalize} #{self.app_dump.dbtype} dump FAILED! :rotating_light:",
    "fields" => [],
    "color" => "danger"
   }

    if(!self.additionaldata[:error].blank?)
      attachment["fields"].push({"title" => "Details", "value" => self.additionaldata[:error], "short" => false})
    else
      attachment["fields"].push({"title" => "Details", "value" => "No details available", "short" => false})
    end

    SlackNotification.post({attachment: attachment, channel: "#deploys", username: "Engineering Database Tools Notification"})
  end





end
