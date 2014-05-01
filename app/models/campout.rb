# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class Campout
  extend TimeUtils

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

  def self.deploy_start_notification(deploy)
    location = (deploy.app_location.nil? ? deploy.location : deploy.app_location.url)
    message = ":mega: #{deploy.coder.name} is deploying the #{deploy.branch} branch of #{deploy.application.name} to #{location}."
    delay.speak(message)
  end

  def self.deploy_notification(deploy,options={})
    location = (deploy.app_location.nil? ? deploy.location : deploy.app_location.url)
    if(options['from_cli'])
      message = "#{deploy.coder.name} uploaded a deploy log for #{deploy.application.name} to #{location} using the cli. Details: #{deploy.campout_url}"
    else
      if(deploy.success?)
        message = ":checkered_flag: #{deploy.coder.name} deployed the #{deploy.branch} branch of #{deploy.application.name} to #{location}. Details: #{deploy.campout_url}"
      else
        message = ":warning: The deploy for #{deploy.application.name} to #{location} has FAILED!. Details: #{deploy.campout_url}"
      end
    end
    delay.speak(message)
  end

  def self.dump_notification_start(dump,coder)
    time_period_string = time_period_to_s(dump.average_runtime)
    message = ":mega: #{coder.name} has started a #{dump.dbtype} database dump for #{dump.application.name}. This typically takes #{time_period_string}"
    delay.speak(message)
  end


  def self.copy_notification_start(app_copy,coder)
    time_period_string = time_period_to_s(app_copy.average_runtime)
    message = ":mega: #{coder.name} has started a production => development database copy for #{app_copy.application.name}. This typically takes #{time_period_string}"
    delay.speak(message)
  end

  def self.dump_notification(dump_log)
    if(dump_log.success?)
      message = ":checkered_flag: The #{dump_log.app_dump.dbtype} database for #{dump_log.application.name} has been dumped (compressed size: #{AppDump.humanize_bytes(dump_log.size)})."
    else
      message = ":warning: The #{dump_log.app_dump.dbtype} database dump for #{dump_log.application.name} has FAILED!. Details: #{dump_log.additionaldata[:error]}"
    end
    delay.speak(message)
  end

  def self.copy_notification(copy_log)
    if(copy_log.success?)
      message = ":checkered_flag: The production => development database copy for #{copy_log.application.name} is complete (dump file size: #{AppCopy.humanize_bytes(copy_log.size)})."
    else
      message = ":warning: The production => development database copy for #{copy_log.application.name} has FAILED!. Details: #{copy_log.additionaldata[:error]}"
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
