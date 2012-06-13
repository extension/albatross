# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
class NotificationsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :signin_required  
  
  
  def index
    @applist = Application.all
  end
  
  def show
    @deploy = Deploy.find(params[:id])
  end
  
  def create
    if(deploy = Deploy.create_or_update_from_params(params))
      returninformation = {'message' => 'Updated deploy database', 'success' => true}
      return render :json => returninformation.to_json, :status => :ok
    else
      returninformation = {'message' => 'Unable to create or update the deploy database', 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end    
  end
  
  
end