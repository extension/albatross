# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class Application < ActiveRecord::Base
  attr_accessible :name, :github_url
  has_many :deploys
  has_many :notification_prefs, dependent: :destroy
  has_many :coders_to_notify, through: :notification_prefs, source: :coder, :conditions => "notification_prefs.notify = true", uniq: true
  
  
  before_create :generate_appkey
  
  
  def generate_appkey
    randval = rand
    self.appkey = Digest::SHA1.hexdigest(Settings.session_token+self.name+randval.to_s)
  end
    
end
