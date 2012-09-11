# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
class AuthController < ApplicationController
  skip_before_filter :signin_required
  skip_before_filter :verify_authenticity_token

  def start
  end
    
  def end
    @currentcoder = nil
    session[:coder_id] = nil
    flash[:success] = "You have successfully signed out."
    return redirect_to(root_url)
  end
  
  def success
    authresult = request.env["omniauth.auth"]    
    uid = authresult['uid']
    email = authresult['info']['email']
    name = authresult['info']['name']
    nickname = authresult['info']['nickname']

    logger.debug "#{authresult.inspect}"
     
    coder = Coder.find_by_uid(uid)
    
    if(coder)
      coder.update_attributes(:nickname => nickname, :name => name)
      if(!coder.coder_emails.map(&:email).include?(email))
        coder.coder_emails.create(email: email)
      end
      coder.login
      session[:coder_id] = coder.id
      @currentcoder = coder
      flash[:success] = "You are signed in as #{@currentcoder.name}"
    else
      flash[:error] = "Unable to find your account, please contact an Engineering staff member to create your account"
    end
  
    return redirect_to(root_url)

  end
  
  def failure
    raise request.env
  end
  
  

end