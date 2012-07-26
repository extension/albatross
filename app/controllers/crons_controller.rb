# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
class CronsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :signin_required, :except => [:create]     
  
  def index
    deploylist_scope = CronLog.order("started_at DESC")
    
    if(params[:cron] and cron = Cron.find_by_id(params[:cron]))
      deploylist_scope = deploylist_scope.bycron(cron)
    end
        
    @cronlogs = deploylist_scope.page(params[:page])
  end
  
  def show
    @cron = Cron.find(params[:id])
    @cronlogs = @cron.cron_logs.order("started_at DESC").page(params[:page])
  end

end