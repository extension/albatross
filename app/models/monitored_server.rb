# === COPYRIGHT:
# Copyright (c) North Carolina State University
# === LICENSE:
# see LICENSE file

class MonitoredServer < ActiveRecord::Base
  serialize :sysinfo

  validates :name, :presence => true, :uniqueness => true

  has_one :application
  has_many :cronmons, :dependent => :destroy
  has_one :oauth_application, class_name: 'Doorkeeper::Application', as: :owner, dependent: :destroy

  scope :active, where(is_active: true)

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
    cs
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

end
