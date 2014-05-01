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


  def servers
    @serverlist = CronmonServer.active.all
    cronmon_breadcrumbs
  end

  def server
    @server = CronmonServer.find(params[:id])
    cronmon_breadcrumbs([@server.name])
  end

  def index
  end

  def show
    @cronmon = Cronmon.find(params[:id])
    @cronlogs = @cronmon.cronmon_logs.order("finish DESC").page(params[:page])
    cronmon_breadcrumbs([[@cronmon.cronmon_server.name,server_cronmons_path(id: @cronmon.cronmon_server.id)],@cronmon.label])
  end

  def showlog
    @cronmon = Cronmon.find(params[:id])
    @cronmon_log = CronmonLog.find(params[:log_id])
    cronmon_breadcrumbs([[@cronmon.cronmon_server.name,server_cronmons_path(id: @cronmon.cronmon_server.id)],
                         [@cronmon.label,cronmon_path(@cronmon)],
                         "ID##{@cronmon_log.id} (#{@cronmon_log.start.to_s})"])

  end

  private

  def cronmon_breadcrumbs(endpoints = [])
    add_breadcrumb("Monitored Servers", :servers_cronmons_path)
    if(!endpoints.blank?)
      endpoints.each do |endpoint|
        if(endpoint.is_a?(Array))
          add_breadcrumb(endpoint[0],endpoint[1])
        else
          add_breadcrumb(endpoint)
        end
      end
    end
  end

end
