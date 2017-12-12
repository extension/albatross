# === COPYRIGHT:
# Copyright (c) North Carolina State University
# === LICENSE:
# see LICENSE file

class MonitoredServerHeartbeat < ActiveRecord::Base
  belongs_to :monitored_server
end
