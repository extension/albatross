# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class Coder < ActiveRecord::Base
  attr_accessible :uid, :name, :nickname, :email
  
  def login
    self.update_attribute(:last_login_at, Time.now.utc)
  end
  
end
