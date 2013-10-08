# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class Application < ActiveRecord::Base
  attr_accessible :name, :github_url

  validates :name, :presence => true, :uniqueness => {:case_sensitive => false} 

  has_many :deploys
  has_many :coders_to_notify, through: :notification_prefs, source: :coder, :conditions => "notification_prefs.notify = true", uniq: true
  has_many :app_dumps, dependent: :destroy
  has_one  :app_copy, dependent: :destroy
  has_many :app_locations, dependent: :destroy
  before_create :generate_appkey


  def generate_appkey
    randval = rand
    self.appkey = Digest::SHA1.hexdigest(Settings.session_token+self.name+randval.to_s)
  end

  def app_location_for_location(location)
    self.app_locations.where(location: location).first
  end

  def lastest_production_deploy
    production_location = self.app_locations.production.first
    production_location.latest_deploy
  end


end
