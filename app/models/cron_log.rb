# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class CronLog < ActiveRecord::Base
  
  belongs_to :cron
  scope :bycron, lambda{|cron| where(:cron_id => cron.id)}
  
  
  def self.create_or_update_from_params(provided_params)
    
    cron = Cron.find_or_create_by_name(:name => provided_params['cron_name'])
    
    if(provided_params['stdout'] and provided_params['server'])
      
      cron_log = CronLog.create(provided_params[:cron_log])
      cron_log.cron = cron
      cron_log.save!

    end

    cron

  end
  
  def success?
    self.stderr.blank?
  end
    
  
end
