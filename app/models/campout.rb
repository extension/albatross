# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class Campout

  def self.speak(msg)
    room.speak(msg)
  end
  
  def self.verbose_speak(msg,sound=nil)
    if(sound)
      verbose_room.play(sound)
    end
    verbose_room.speak(msg)
  end
  
  def self.verbose_paste(text)
    verbose_room.paste(text)
  end
  
  def self.campfire_connection
    @campfire || Tinder::Campfire.new(Settings.campfire_domain,token: Settings.campfire_token)
  end
  
  def self.room
    @room || campfire_connection.find_room_by_id(Settings.campfire_room)
  end
  
  def self.verbose_room
    @verbose_room || campfire_connection.find_room_by_id(Settings.campfire_verbose_room)
  end
  
  def self.deploy_notification(deploy,options={})
    if(options['from_cli'])
      message = "#{deploy.coder.name} uploaded a deploy log for #{deploy.application.name} to #{deploy.location} using the cli. Details: #{deploy.campout_url}"
    else
      message = "#{deploy.coder.name} deployed #{deploy.application.name} to #{deploy.location}. Details: #{deploy.campout_url}"
    end
      
    delay.speak(message)
  end
  
  def self.verbose_deploy_start_notification(deploy)
    message = "#{deploy.coder.name} is starting a deploy of #{deploy.application.name} to #{deploy.location}."
    delay.verbose_speak(message,'pushit')
  end
  
  def self.verbose_deploy_finish_notification(deploy,options={})
    if(options['from_cli'])
      message = "#{deploy.coder.name} uploaded a deploy log for #{deploy.application.name} to #{deploy.location} using the cli. Details: #{deploy.campout_url}"
    else
      message = "#{deploy.coder.name} deployed #{deploy.application.name} to #{deploy.location}. Details: #{deploy.campout_url}"
    end
    delay.verbose_speak(message)
  end
  
  
  
end