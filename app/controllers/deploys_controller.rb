# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
class DeploysController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :signin_required, :only => [:setcomment]   
  
  
  def index      
    @deploylist = Deploy.order("start DESC").page(params[:page])
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
  
  
  def setcomment
    @deploy = Deploy.find_by_id(params[:id])
    if(@deploy)
      @deploy.update_attribute(:comment,params[:deploy][:comment])
    end

    respond_to do |format|
      format.js
    end
  end
  
  def fakeit
    if(params[:success])
      returninformation = {'message' => 'Updated deploy database', 'success' => true}
      return render :json => returninformation.to_json, :status => :ok
    else
      returninformation = {'message' => 'Unable to create or update the deploy database', 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end    
  end
  

  def recent
    @deploylist = Deploy.production_listing.includes(:app_location).limit(50)
  end

  def production
    deploylist_scope = Deploy.production_listing.includes(:app_location)
    
    if(params[:coder] and @coder = Coder.find_by_id(params[:coder]))
      deploylist_scope = deploylist_scope.bycoder(@coder)
    end
    
    if(params[:application] and @application = Application.find_by_id(params[:application]))
      deploylist_scope = deploylist_scope.byapplication(@application)
    end
            
    @deploylist = deploylist_scope.page(params[:page])
  end

  
  

end