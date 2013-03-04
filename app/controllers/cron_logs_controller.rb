# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
class CronLogsController < ApplicationController
  skip_before_filter :verify_authenticity_token  
  before_filter :signin_required, :except => [:create]   
  
  def show
    @cronlog = CronLog.find(params[:id])
  end
  
  def create
    if(params[:cron_name])
      if(cronlog = CronLog.create_or_update_from_params(params))
        returninformation = {'message' => 'Updated cron logs database', 'success' => true}
        return render :json => returninformation.to_json, :status => :ok
      else
        returninformation = {'message' => 'Unable to create or update the cron logs database', 'success' => false}
        return render :json => returninformation.to_json, :status => :unprocessable_entity
      end
    end    
  end
  
end