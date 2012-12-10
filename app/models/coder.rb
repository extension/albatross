# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class Coder < ActiveRecord::Base
  attr_accessible :uid, :name, :nickname, :email
  has_many :deploys
  has_many :notification_prefs, dependent: :destroy
  has_many :coder_emails
  
  after_create :set_data_key

  def login
    self.update_attribute(:last_login_at, Time.now.utc)
  end
  
  def self.find_by_deploy_email(email)
    if(!(coder_email = CoderEmail.find_by_email(email)))
      coder_email = CoderEmail.create(coder_id: self.coderbot_id, email: email)
    end
    coder_email.coder
  end


  def self.find_or_create_with_options(options)
    if(!(coder = self.find_by_email(options[:email])))
      coder = self.create(email: options[:email], name: options[:name])
    end
    coder
  end

  def self.coderbot
    find(self.coderbot_id)
  end

  def self.coderbot_id
    1
  end

  def set_data_key
    randval = rand
    self.update_attribute(:data_key, Digest::SHA1.hexdigest(Settings.session_token+self.id.to_s+self.uid+randval.to_s))
  end
  
end
