# === COPYRIGHT:
# Copyright (c) North Carolina State University
# === LICENSE:
# see LICENSE file

class CronmonLog < ActiveRecord::Base
  
  belongs_to :cronmon
  has_one :cronmon_log_output
  accepts_nested_attributes_for :cronmon_log_output

  before_save :set_runtime

  def set_runtime
    if(!self.finish.blank? and !self.start.blank?)
      self.runtime = self.finish - self.start
    end
  end


end