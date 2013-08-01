# === COPYRIGHT:
# Copyright (c) North Carolina State University
# === LICENSE:
# see LICENSE file

class Cronmon < ActiveRecord::Base
  
  belongs_to :cronmon_server
  has_many :cronmon_logs
  validates :label, :presence => true

  def save_log(provided_params)
    create_options = {}
    create_options[:command] = provided_params[:command] || 'unknown'
    create_options[:start]   = provided_params[:start] 
    create_options[:finish]   = provided_params[:finish]
    create_options[:success]   = provided_params[:success]
    create_options[:cronmon_log_output_attributes] = {stdout: provided_params[:stdout], stderr: provided_params[:stderr]}
    self.cronmon_logs.create(create_options)
  end
  
end