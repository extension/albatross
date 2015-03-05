# === COPYRIGHT:
# Copyright (c) 2014 North Carolina State University
# === LICENSE:
# see LICENSE file

class EngbotLog < ActiveRecord::Base

  attr_accessible :slack_channel_id, :slack_channel_name, :slack_user_id, :slack_user_name, :command, :commandtext


end
