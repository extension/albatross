# === COPYRIGHT:
# Copyright (c) North Carolina State University
# === LICENSE:
# see LICENSE file

class Cronmon < ActiveRecord::Base

  belongs_to :cronmon_server
  has_many :cronmon_logs, :dependent => :destroy
  validates :label, :presence => true

  def save_log(provided_params)
    create_options = {}
    create_options[:command] = provided_params[:command] || 'unknown'
    create_options[:start]   = provided_params[:start]
    create_options[:finish]   = provided_params[:finish]
    if(provided_params[:runtime] and provided_params[:runtime].to_f > 0)
      create_options[:runtime] = provided_params[:runtime].to_f
    end
    create_options[:success]   = provided_params[:success]
    create_options[:cronmon_log_output_attributes] = {stdout: provided_params[:stdout], stderr: provided_params[:stderr]}
    if(cronmon_log = self.cronmon_logs.create(create_options))
      self.cronmon_server.touch(:last_cron_at)
      cronmon_log
    else
      nil
    end
  end


  def lastlog
    self.cronmon_logs.order('start DESC').first
  end

end
