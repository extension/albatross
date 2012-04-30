# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class Coder < ActiveRecord::Base
  attr_accessible :uid, :name, :nickname, :email
  has_many :deploys
  
  def login
    self.update_attribute(:last_login_at, Time.now.utc)
  end
  
  def self.find_or_create_with_options(options)
    if(!(coder = self.find_by_email(options[:email])))
      coder = self.create(email: options[:email], name: options[:name])
    end
    coder
  end
  
end
