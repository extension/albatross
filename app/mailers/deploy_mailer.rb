# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class DeployMailer < ActionMailer::Base
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

  def mailtest(options = {})
    @subject = "This is a test of the Deploys Email System."
    @coder = options[:coder]  
    @recipient = options[:recipient]    
    return_email = mail(to: @recipient.email, subject: @subject)
    return_email
  end

end
