# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class Deploy < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  default_url_options[:host] = Settings.urlwriter_host
  default_scope where("finish IS NOT NULL")
  
  
  
  attr_accessible :application, :coder, :capatross_id, :previous_revision, :deployed_revision, :location, :start, :finish, :success
  belongs_to :application
  belongs_to :coder
  has_one :deploy_log
  
  before_save :standardize_location
  
  
  scope :byapplication, lambda{|application| where(:application_id => application.id)}
  scope :bylocation, lambda{|location| where(:location => location)}
  scope :bycoder, lambda{|coder| where(:coder_id => coder.id)}

  
  def self.create_or_update_from_params(provided_params)
    if(!provided_params['appkey'] or !provided_params['capatross_id'] or !provided_params['deployer_email'])
      return nil
    end
    
    if(!(deploy = self.unscoped.find_by_capatross_id(provided_params['capatross_id'])))

      coder = Coder.find_or_create_with_options({email: provided_params['deployer_email'], name: provided_params['deployer_name']})
      if(!(application = Application.find_by_appkey(provided_params['appkey'])))
        return nil
      end

      deploy = Deploy.new(capatross_id: provided_params['capatross_id'], coder: coder, application: application)

    end

    deploy.previous_revision = provided_params['previous_revision']
    deploy.deployed_revision = provided_params['deployed_revision']
    deploy.location = provided_params['location']
    deploy.start = provided_params['start']
    deploy.finish = provided_params['finish']
    deploy.success = provided_params['success']
    deploy.comment = provided_params['comment']
    deploy.save!
    
    if(provided_params['deploy_log'])
      deploy_log = DeployLog.find_or_create_by_deploy(deploy)
      deploy_log.update_attribute(:output,provided_params['deploy_log'])
    end
    
    # notifications
    if(deploy.finish.nil?)
      # first post, verbose only
      Campout.verbose_deploy_start_notification(deploy)
    else
      Campout.deploy_notification(deploy,{'from_cli' => provided_params['from_cli']})
      Campout.verbose_deploy_finish_notification(deploy,{'from_cli' => provided_params['from_cli']})
      self.application.coders_to_notify.each{|recipient| DeployMailer.delay.deploy(recipient: recipient.email, deploy: self) }
    end
  
    deploy
  end
  
  def self.coders_with_deploys
    Deploy.group(:coder).count
  end
  
  def self.applications_with_deploys
    Deploy.group(:application).count
  end
  
  def self.locations_with_deploys
    Deploy.group(:location).count
  end
  
  def standardize_location
    if(self.location == 'prod')
      self.location = 'production'
    elsif(self.location == 'dev')
      self.location = 'development'
    elsif(self.location == 'demo')
      self.location = 'staging'
    end
  end
    
  def campout_url
    deploy_url(self)
  end
        
    
end
