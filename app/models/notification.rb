# === COPYRIGHT:
#  Copyright (c) North Carolina State University
#  Developed with funding for the National eXtension Initiative.
# === LICENSE:
# 
#  see LICENSE file

class Notification < ActiveRecord::Base
  ## attributes
  serialize :additionaldata
  serialize :results
  attr_accessible :notifiable, :notifiable_type, :notifiable_id, :notification_type, :delivery_time, :additionaldata, :processed, :results, :process_on_create

  ## validations

  ## filters
  before_create :set_delivery_time
  after_create  :queue_notification

  ## associations
  belongs_to :notifiable, :polymorphic => true


  ## scopes


  ## constants
  ## Notification types
  CRONMON_ERROR = 100

  def self.code_to_constant_string(code)
    constantslist = self.constants
    constantslist.each do |c|
      value = self.const_get(c)
      if(value.is_a?(Fixnum) and code == value)
        return c.to_s.downcase
      end
    end
  
    # if we got here?  return nil
    return nil
  end

  def set_delivery_time
    if(self.delivery_time.blank?)
      self.delivery_time = Time.now
    end
  end

  def queue_notification
    if(Settings.redis_enabled and !self.process_on_create?)
      self.class.delay_until(self.delivery_time).delayed_notify(self.id)
    else
      self.notify
    end
  end

  def self.delayed_notify(record_id)
    if(record = find_by_id(record_id))
      record.notify
    end
  end

  def notify
    method_name = self.class.code_to_constant_string(self.notification_type)
    methods = self.class.instance_methods.map{|m| m.to_s}
    if(methods.include?(method_name))
      begin 
        self.send(method_name)
        self.update_attributes({processed: true})
      rescue NotificationError => e
        self.update_attributes({results: "ERROR! #{e.message}"})
      end
    else
      self.update_attributes({results: "ERROR! No method for this notification type"})
    end
  end


  def cronmon_error
    EventMailer.cronmon_error({cronmon_log: self.notifiable, notification: self}).deliver
  end




end