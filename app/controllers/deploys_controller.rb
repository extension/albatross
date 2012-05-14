# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
class DeploysController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :signin_required, :only => [:setcomment]   
  
  
  def index
    deploylist_scope = Deploy.order("start DESC")
    
    if(params[:coder] and coder = Coder.find_by_id(params[:coder]))
      deploylist_scope = deploylist_scope.bycoder(coder)
    end
    
    if(params[:application] and application = Application.find_by_id(params[:application]))
      deploylist_scope = deploylist_scope.byapplication(application)
    end
    
    if(params[:location])
      deploylist_scope = deploylist_scope.bylocation(params[:location])
    end
        
    @deploylist = deploylist_scope.page(params[:page])
  end
  
  def show
    @deploy = Deploy.find(params[:id])
  end
  
  def create
    if(deploy = Deploy.create_or_update_from_params(params))
      returninformation = {'message' => 'Updated deploy database', 'success' => true}
      return render :json => returninformation.to_json, :status => :ok
    else
      returninformation = {'message' => 'Update to create or update the deploy database', 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end    
  end
  
  
  def setcomment
    @deploy = Deploy.find_by_id(params[:id])
    if(@deploy)
      @deploy.update_attribute(:comment,params[:deploy][:comment])
    end
    
    respond_to do |format|
      format.json { respond_with_bip(@deploy) }
    end
  end
  
  

end