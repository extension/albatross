# === COPYRIGHT:
# Copyright (c) North Carolina State University
# === LICENSE:
# see LICENSE file

class Cronmon < ActiveRecord::Base
  
  belongs_to :cronmon_server
  has_many :cronmon_logs
  
end