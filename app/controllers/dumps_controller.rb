# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class DumpsController < ApplicationController
  skip_before_filter :verify_authenticity_token


  def getdata
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

end