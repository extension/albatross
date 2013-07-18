# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
class CronmonsController < ApplicationController
  skip_before_filter :verify_authenticity_token  
  before_filter :signin_required, :except => [:register, :log]
  doorkeeper_for :register


  def log
  end

  def register
    if(!params[:hostname])
      returninformation = {'message' => 'Missing hostname'}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    elsif(cs = CronmonServer.where(name: params[:hostname]).first and !TRUE_VALUES.include?(params[:force]))
      returninformation = {'message' => "A server named #{params[:hostname]} is already registered"}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    elsif(cs = CronmonServer.register(params[:hostname],true) and oauth = cs.oauth_application)
      returninformation = {'auth' => {'name' => cs.name, 'uid' => oauth.uid, 'secret' => oauth.secret}, 'message' => 'Server registered.'}      
      return render :json => returninformation.to_json, :status => :ok
    else
      returninformation = {'message' => 'An unknown error occurred'}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end 
  end   
  
end