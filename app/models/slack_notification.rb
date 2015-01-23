# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class SlackNotification
  extend TimeUtils

  attr_accessor :message, :attachment, :slack

  def initialize(options = {})
    username = options[:username] || "Engineering Notifier"
    channel = options[:channel] || Settings.slack_channel
    @slack = Slack::Notifier.new(Settings.slack_webhook)
    @slack.username = username
    @slack.channel = channel
    @message = options[:message] || ''
    @attachment = options[:attachment]
    self
  end

  def post
    if(self.attachment)
      self.slack.ping(self.message, attachments: [self.attachment], icon_url: 'https://engineering.extension.org/favicon.ico')
    else
      self.slack.ping(self.message, icon_url: 'https://engineering.extension.org/favicon.ico')
    end
  end

  def self.post(options = {})
    if(notification = self.new(options))
      notification.post
    end
  end


  def self.speak(msg)
    slack_connection.ping(msg, icon_url: 'https://engineering.extension.org/favicon.ico')
  end



  def self.dump_notification_start(dump,coder)
    time_period_string = time_period_to_s(dump.average_runtime)
    message = ":mega: #{coder.name} has started a #{dump.dbtype} database dump for #{dump.application.name}. This typically takes #{time_period_string}"
    delay.speak(message)
  end


  def self.copy_notification_start(app_copy,coder)
    time_period_string = time_period_to_s(app_copy.average_runtime)
    message = ":mega: #{coder.name} has started a production => development database copy for #{app_copy.application.name}. This typically takes #{time_period_string}"
    delay.speak(message)
  end

  def self.dump_notification(dump_log)
    if(dump_log.success?)
      message = ":checkered_flag: The #{dump_log.app_dump.dbtype} database for #{dump_log.application.name} has been dumped (compressed size: #{AppDump.humanize_bytes(dump_log.size)})."
    else
      message = ":warning: The #{dump_log.app_dump.dbtype} database dump for #{dump_log.application.name} has FAILED!. Details: #{dump_log.additionaldata[:error]}"
    end
    delay.speak(message)
  end

  def self.copy_notification(copy_log)
    if(copy_log.success?)
      message = ":checkered_flag: The production => development database copy for #{copy_log.application.name} is complete (dump file size: #{AppCopy.humanize_bytes(copy_log.size)})."
    else
      message = ":warning: The production => development database copy for #{copy_log.application.name} has FAILED!. Details: #{copy_log.additionaldata[:error]}"
    end
    delay.speak(message)
  end

end
