# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class DumpsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
  end

  def show
    @appdump = AppDump.find(params[:id])
  end


  def dumpinfo
    if(params[:appkey])
      application = Application.find_by_appkey(params[:appkey])
    elsif(params[:appname])
      application = Application.find_by_name(params[:appname])
    end

    if(application.nil?)
      returninformation = {'message' => 'Unknown application', 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end

    dbtype = params[:dbtype] || 'production'
    app_data = application.app_dumps.where(dbtype: dbtype).first

    if(!app_data)
      returninformation = {'message' => 'Dump file does not exist', 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end

    dumpinfo = app_data.dumpinfo
    if(!dumpinfo['success'])
      returninformation = {'message' => dumpinfo['error'], 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end

    return render :json => dumpinfo.to_json, :status => :ok
  end

  def do
    if(params[:appkey])
      application = Application.find_by_appkey(params[:appkey])
    elsif(params[:appname])
      application = Application.find_by_name(params[:appname])
    end

    if(application.nil?)
      returninformation = {'message' => 'Unknown application', 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end

    dbtype = params[:dbtype] || 'production'
    appdump = application.app_dumps.where(dbtype: dbtype).first

    if(!appdump)
      returninformation = {'message' => 'Dump file does not exist', 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end

    if(params['dumper_email'])
      coder = Coder.find_by_deploy_email(params['deployer_email'])
    end

    if(!coder)
      coder = Coder.coderbot
    end


    appdump.delay.dump({announce: true, coder: coder})
    returninformation = {'message' => 'Scheduled database dump', 'success' => true}
    return render :json => returninformation.to_json, :status => :ok
  end

end