# === COPYRIGHT:
# Copyright (c) North Carolina State University
# === LICENSE:
# see LICENSE file

class CronmonLog < ActiveRecord::Base
  
  belongs_to :cronmon
  has_one :cronmon_log_output
  
end