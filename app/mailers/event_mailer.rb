# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class EventMailer < ActionMailer::Base
  default_url_options[:host] = 'deploys.extension.org'
  default from: "exsys@extension.org"
  default bcc: "systemsmirror@extension.org"

  def deploy(options = {})
    @deploy = options[:deploy]
    @app = @deploy.application
    @subject = "#{@app.name} (#{@app.location}) deployment notification"
    @coder = @deploy.coder
    @recipient = options[:recipient]
    
    return_email = mail(to: @recipient.email, subject: @subject)
    return_email
  end
  
  def cron_error(options = {})
    @cronlog = options[:cron_log]
    @server = @cronlog.server
    @cron_name = @cronlog.cron.name
    @subject = "#{@server}: error encountered running #{@cron_name}"
    @recipient = Settings.cron_notification_email
    
    return_email = mail(to: @recipient, subject: @subject)
    return_email
  end

  def mailtest(options = {})
    @subject = "This is a test of the Deploys Email System."
    @coder = options[:coder]  
    @recipient = options[:coder]    
    return_email = mail(to: @recipient.email, subject: @subject)
    return_email
  end

  def cronmon_error(options = {})
    @cronmon_log = options[:cronmon_log]
    @cronmon = @cronmon_log.cronmon
    @server = @cronmon.cronmon_server

    @recipient = Settings.cron_notification_email
    @subject = "#{@server.name}: error encountered running #{@cronmon.label}"

    return_email = mail(to: @recipient, subject: @subject)
    return_email
  end

end
