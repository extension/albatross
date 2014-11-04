# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

require 'pp'


class DeploysController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :signin_required, :only => [:setcomment]


  def index
    @deploylist = scopeit(Deploy.order("start DESC")).page(params[:page])
  end

  def show
    @deploy = Deploy.find(params[:id])
    @show_edit_comment = true
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
    @show_edit_comment = true

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
    @deploylist = scopeit(Deploy.production_listing.includes(:app_location)).limit(20)
  end

  def production
    @deploylist = scopeit(Deploy.production_listing.includes(:app_location)).page(params[:page])
  end

  def githubnotification
    if(gn = GithubNotification.create_from_params(params))
      gn.application.queue_fetch
      returninformation = {'message' => 'Logged notification', 'success' => true}
      return render :json => returninformation.to_json, :status => :ok
    else
      returninformation = {'message' => 'Unable to log notification', 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end
  end


  private

  def scopeit(base_scope)

    if(params[:coder] and @coder = Coder.find_by_id(params[:coder]))
      base_scope = base_scope.bycoder(@coder)
    end

    if(params[:application] and @application = Application.find_by_id(params[:application]))
      base_scope = base_scope.byapplication(@application)
    end

    base_scope

  end



end
