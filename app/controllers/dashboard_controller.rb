# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class DashboardController < ActionController::Base
  layout 'application'
  
  def index
    @deploylist = Deploy.production_listing.includes(:app_location).page(params[:page])
  end

end