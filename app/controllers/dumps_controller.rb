# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class DumpsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :validate_data_key, only: [:dumpinfo, :do, :copy]

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

    appdump.delay.dump({announce: true, coder: @coder})
    returninformation = {'message' => 'Scheduled database dump', 'success' => true}
    return render :json => returninformation.to_json, :status => :ok
  end

  def copy
    if(params[:appkey])
      application = Application.find_by_appkey(params[:appkey])
    elsif(params[:appname])
      application = Application.find_by_name(params[:appname])
    end

    if(application.nil?)
      returninformation = {'message' => 'Unknown application', 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end

    appcopy = application.app_copy

    if(!appcopy)
      returninformation = {'message' => 'No application copy configuration exists.', 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end

    appcopy.request_notification(@coder)

    appcopy.delay_for(1.minute).copy({announce: true, coder: @coder})
    returninformation = {'message' => 'Scheduled database copy. Please place the staging application in maintenance mode.', 'success' => true}
    return render :json => returninformation.to_json, :status => :ok
  end

  def validate_data_key
    if(!params[:data_key])
      returninformation = {'message' => 'Data operations require that you add your personal data_key to your exdata settings.', 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end

    if(!(@coder = Coder.find_by_data_key(params[:data_key])))
      returninformation = {'message' => 'The personal data_key that you provided is not valid. Check it and try again.', 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end
  end

end
