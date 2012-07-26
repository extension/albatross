# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class Cron < ActiveRecord::Base
  
  has_many :cron_logs
  
  def toggle_notification
    self.error_notification = self.error_notification ? false : true
    self.save
  end
  

end
