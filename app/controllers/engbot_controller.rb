# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
class EngbotController < ApplicationController


  def ask
    # verify token
    if(params[:token].blank? or params[:token] != Settings.slack_engbot_token)
      return render :text => 'Invalid Token', :status => :unprocessable_entity
    end

    if(engbot_log = EngbotLog.create(slack_channel_id: params[:channel_id],
                                     slack_channel_name: params[:channel_name],
                                     slack_user_id: params[:user_id],
                                     slack_user_name: params[:user_name],
                                     command: params[:command],
                                     commandtext: params[:text]))
      return render :text => engbot_log.message, :status => :ok
    else
      # return object errors maybe, but not today
      return render :text => 'An error occurred processing your command', :status => :unprocessable_entity
    end
  end

end
