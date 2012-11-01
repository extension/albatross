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
      if(deploy.success?)
        message = "#{deploy.coder.name} deployed #{deploy.application.name} to #{deploy.location}. Details: #{deploy.campout_url}"
      else
        message = ":warning: The deploy for #{deploy.application.name} to #{deploy.location} has FAILED!. Details: #{deploy.campout_url}"
      end
    end
    delay.speak(message)
  end

  def self.dump_notification_start(dump,coder)
    message = ":mega: #{coder.name} has started a #{dump.dbtype} database dump for #{dump.application.name}"
    delay.speak(message)
  end


  def self.dump_notification(dump_log)
    if(dump_log.success?)
      message = ":mega: The #{dump_log.app_dump.dbtype} database for #{dump_log.application.name} has been dumped (compressed size: #{AppDump.humanize_bytes(dump_log.size)}). Use 'capatross getdata' to download."
    else
      message = ":warning: The #{dump_log.app_dump.dbtype} database dump for #{dump_log.application.name} has FAILED!. Details: #{dump_log.additionaldata[:error]}"
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
      if(deploy.success?)
        message = "#{deploy.coder.name} deployed #{deploy.application.name} to #{deploy.location}. Details: #{deploy.campout_url}"
        sound = 'tada'
      else
        message = ":warning: The deploy for #{deploy.application.name} to #{deploy.location} has FAILED!. Details: #{deploy.campout_url}"
        sound = 'dangerzone'
      end
    end
    delay.verbose_speak(message,sound)
  end



end