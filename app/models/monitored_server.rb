# === COPYRIGHT:
# Copyright (c) North Carolina State University
# === LICENSE:
# see LICENSE file

class MonitoredServer < ActiveRecord::Base
  class << self
    include Rails.application.routes.url_helpers
    default_url_options[:host] = Settings.urlwriter_host
  end

  serialize :sysinfo

  validates :name, :presence => true, :uniqueness => true

  has_one :application
  has_many :cronmons, :dependent => :destroy
  has_many :monitored_server_reboot_checks
  has_many :monitored_server_heartbeats
  has_one :oauth_application, class_name: 'Doorkeeper::Application', as: :owner, dependent: :destroy

  scope :active, where(is_active: true)
  scope :needs_reboot, where(needs_reboot: true)

  MAX_PURPOSE_LENGTH = 250

  def self.register(name,reset_oauth_application=false)
  	if(monserv = self.where(name: name).first)
      if(reset_oauth_application)
        if(oa = monserv.oauth_application)
          oa.destroy
          monserv.create_oauth_application(name: "cronmon-#{monserv.name}", redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
        else
          monserv.create_oauth_application(name: "cronmon-#{monserv.name}", redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
        end
      end
  	else
      if(monserv = create(name: name))
        monserv.create_oauth_application(name: "cronmon-#{monserv.name}", redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
      end
    end
    monserv
  end

  def find_or_create_cronmon_by_label(label)
    label = 'unknown' if label.nil?
    if(!cronmon = self.cronmons.where(label: label).first)
      cronmon = self.cronmons.create(label: label)
    end
    cronmon
  end

  def purpose=(provided_purpose)
    if(provided_purpose.length > MAX_PURPOSE_LENGTH)
      write_attribute(:purpose, provided_purpose.truncate(MAX_PURPOSE_LENGTH))
    else
      write_attribute(:purpose, provided_purpose)
    end
  end

  def log_rebootcheck(needs_reboot,rebootinfo)
    msrc = self.monitored_server_reboot_checks.create(needs_reboot: needs_reboot, rebootinfo: rebootinfo)
    self.update_attributes(needs_reboot: needs_reboot, last_rebootcheck_at: msrc.created_at)
  end

  def log_heartbeat(purpose)
    mshb = self.monitored_server_heartbeats.create
    attributes_to_update = {last_heartbeat_at: mshb.created_at}
    if(!purpose.nil?)
      attributes_to_update[:purpose] = purpose
    end
    self.update_attributes(attributes_to_update)
  end

  def self.server_list_url
    servers_cronmons_url
  end


  def self.reboot_notification
      if(self.needs_reboot.count > 0 )
        post_options = {}
        post_options[:channel] = Settings.systems_slack_channel
        post_options[:username] = "Cronmon Reboot Notification"
        post_options[:icon_emoji] = ':boot:'

        attachment = { "fallback" => ":rotating_light: Some Servers Currently Need Reboots :rotating_light:",
        "text" => ":rotating_light: Some Servers Currently Need Reboots :rotating_light:",
        "fields" => [
          {
            "title" => "Servers",
            "value" => "#{self.needs_reboot.pluck(:name).join(', ')}",
            "short" => false
          }
        ],
        "color" => "danger"
      }

      attachment["fields"].push({"title" => "Details", "value" => self.server_list_url, "short" => false})
      post_options[:attachment] = attachment

      SlackNotification.post(post_options)
    end

  end


end
