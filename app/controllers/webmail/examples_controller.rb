# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Webmail::ExamplesController < ApplicationController
  
  def mailtest
    mail = EventMailer.mailtest(coder: Coder.first, deploy: Deploy.first)
    return render_mail(mail)
  end
  
  def cron_error
    mail = EventMailer.cron_error(cron_log: CronLog.first)
    return render_mail(mail)
  end

  protected
  
  def render_mail(mail)
    # send it through the inline style processing
    inlined_content = mail.body.to_s
    render(:text => inlined_content, :layout => false)
  end
  
end