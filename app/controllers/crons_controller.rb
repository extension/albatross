# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
class CronsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :signin_required, :except => [:create]     
  
  def index     
    @cronlogs = CronLog.includes(:cron).order("finished_at DESC").page(params[:page])
  end
  
  def show
    @cron = Cron.find(params[:id])
    @cronlogs = @cron.cron_logs.order("finished_at DESC").page(params[:page])
  end

end