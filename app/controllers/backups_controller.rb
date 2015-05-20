# === COPYRIGHT:
# Copyright (c) 2015 North Carolina State University
# === LICENSE:
# see LICENSE file

class BackupsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :validate_backup_key, only: [:log, :ping]

  def ping
    returninformation = {'message' => 'Pong.', 'success' => true}
    return render :json => returninformation.to_json, :status => :ok
  end

  def log
    if(!params[:results])
      returninformation = {'message' => 'Provided results are not in the correct format', 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    elsif(backuplog = Backup.save_log(params[:results]))
      returninformation = {'message' => 'Logged backup', 'success' => true}
      return render :json => returninformation.to_json, :status => :ok
    else
      returninformation = {'message' => 'Unable to log backup information', 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end
  end

  def show
  end

  def validate_backup_key
    if(!params[:backup_key])
      returninformation = {'message' => 'Backup logging requires that the backup key be provided as part of the log.', 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end

    if(params[:backup_key] != Settings.backup_key)
      returninformation = {'message' => 'The backup key provided was not valid.', 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end
  end

end
