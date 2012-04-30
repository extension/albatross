# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
class DeploysController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def index
  end
  
  def production
  end
  
  def show
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