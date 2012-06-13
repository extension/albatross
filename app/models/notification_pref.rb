# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class NotificationPref < ActiveRecord::Base
  
  belongs_to :application
  belongs_to :coder
  
  scope :byapplication, lambda{|application| where(:application_id => application.id)}
  scope :bycoder, lambda{|coder| where(:coder_id => coder.id)}


end
