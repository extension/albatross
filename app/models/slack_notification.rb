# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class SlackNotification

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

end
