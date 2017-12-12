# === COPYRIGHT:
# Copyright (c) North Carolina State University
# === LICENSE:
# see LICENSE file

class MonitoredServerRebootCheck < ActiveRecord::Base
  serialize :rebootinfo
  
  belongs_to :monitored_server
end
