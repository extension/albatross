# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class SlackNotification
  include Rails.application.routes.url_helpers
  default_url_options[:host] = Settings.urlwriter_host

  attr_accessor :message, :attachment, :slack, :icon_emoji

  def initialize(options = {})
    username = options[:username] || "Engineering Notifier"
    channel = options[:channel] || Settings.default_slack_channel
    @slack = Slack::Notifier.new(Settings.slack_webhook)
    @slack.username = username
    @slack.channel = channel
    @message = options[:message] || ''
    @attachment = options[:attachment]
    @icon_emoji = options[:icon_emoji]
    self
  end

  def post
    post_parameters = {}
    if(self.attachment)
      post_parameters[:attachments] = [self.attachment]
    end

    if(self.icon_emoji)
      post_parameters[:icon_emoji] = self.icon_emoji
    else
      post_parameters[:icon_emoji] = image_url('askbot.png')
    end

    self.slack.ping(self.message, post_parameters)

  end

  def self.post(options = {})
    if(notification = self.new(options))
      notification.post
    end
  end

end
