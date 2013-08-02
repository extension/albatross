# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
class CronmonsController < ApplicationController
  skip_before_filter :verify_authenticity_token  
  before_filter :signin_required, :except => [:register, :log, :heartbeat]
  doorkeeper_for :register, :log, :heartbeat


  def log
    if(doorkeeper_token and doorkeeper_token.application)
      if(cs = doorkeeper_token.application.owner and cs.is_a?(CronmonServer))
        if(cronmon = cs.find_or_create_cronmon_by_label(params[:label]))
          cronmon.save_log(params)
        end
        returninformation = {'message' => "Found server! #{cs.name}"}      
        return render :json => returninformation.to_json, :status => :ok        
      else
        returninformation = {'message' => 'This log belongs to an unknown cronmon server'}
        return render :json => returninformation.to_json, :status => :unprocessable_entity
      end
    else
      returninformation = {'message' => 'This log belongs to an unknown cronmon server'}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end      
  end

  def heartbeat
    if(doorkeeper_token and doorkeeper_token.application)
      if(cs = doorkeeper_token.application.owner and cs.is_a?(CronmonServer))
        if(params[:sysinfo])
          cs.update_attributes({sysinfo: params[:sysinfo], last_heartbeat_at: Time.now.utc})
        else
          cs.update_attributes({last_heartbeat_at: Time.now.utc})
        end          
        returninformation = {'message' => "Found server! #{cs.name}"}      
        return render :json => returninformation.to_json, :status => :ok        
      else
        returninformation = {'message' => 'This heartbeat belongs to an unknown cronmon server'}
        return render :json => returninformation.to_json, :status => :unprocessable_entity
      end
    else
      returninformation = {'message' => 'This heartbeat belongs to an unknown cronmon server'}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end      
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