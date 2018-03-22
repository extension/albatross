# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class Application < ActiveRecord::Base
  attr_accessible :name, :github_url

  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}

  has_many :deploys, dependent: :destroy
  has_many :coders_to_notify, through: :notification_prefs, source: :coder, :conditions => "notification_prefs.notify = true", uniq: true
  has_many :app_dumps, dependent: :destroy
  has_one  :app_copy, dependent: :destroy
  has_many :app_locations, dependent: :destroy
  before_create :generate_appkey

  scope :active, where(is_active: true)
  scope :wordpress_apps, where(is_wordpress: true)


  def generate_appkey
    randval = rand
    self.appkey = Digest::SHA1.hexdigest(Settings.session_token+self.name+randval.to_s)
  end

  def app_location_for_location(location)
    self.app_locations.where(location: location).first
  end

  def latest_production_deploy
    production_location = self.app_locations.production.first
    production_location.latest_deploy
  end

  def fetch_from_github
    GitFetch.fetch_from_github(self)
  end

  def queue_fetch
    if(!self.fetch_pending?)
      if(Settings.sidekiq_enabled)
        self.update_attribute(:fetch_pending,true)
        self.class.delay_until(Time.now + 10.seconds).delayed_fetch(self.id)
      else
        self.fetch_from_github
      end
    end
  end

  def get_staging_dbname
    if(app_location = staging_location)
      app_location.dbname
    else
      nil
    end
  end

  def get_production_dbname
    if(app_location = production_location)
      app_location.dbname
    else
      nil
    end
  end

  def get_scrubhost_dbname
    if(app_dump = self.app_dumps.where(is_snapshot: false).first)
      app_dump.scrubhost_dbname
    else
      nil
    end
  end

  def production_location
    self.app_locations.where(location: AppLocation::PRODUCTION).first
  end

  def staging_location
    self.app_locations.where(location: AppLocation::STAGING).first
  end


  def self.delayed_fetch(record_id)
    if(record = find_by_id(record_id))
      record.fetch_from_github
    end
  end

  def self.find_by_github_reponame(name)
    # for testing purposes
    name = 'darmok' if (name == 'webhook_testing')
    self.where(github_url: "https://github.com/extension/#{name}").first
  end




end
