# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class Campout

  def self.speak(msg)
    room.speak(msg)
  end

  def self.campfire_connection
    @campfire || Tinder::Campfire.new(Settings.campfire_domain,token: Settings.campfire_token)
  end
  
  def self.room
    @room || campfire_connection.find_room_by_id(Settings.campfire_room)
  end
  
  def self.deploy_notification(deploy)
    delay.speak("#{deploy.coder.name} deployed #{deploy.application.name} to #{deploy.location}. Details: #{deploy.campout_url}")
  end
  
end