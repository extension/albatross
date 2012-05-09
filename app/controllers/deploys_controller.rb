# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
class DeploysController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
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
      returninformation = {'message' => 'Updated deploy database'}
      return render :json => returninformation.to_json, :status => :ok
    else
      returninformation = {'message' => 'Update to create or update the deploy database'}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end    
  end
  

end