# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class Deploy < ActiveRecord::Base
  attr_accessible :application, :coder, :capatross_id, :previous_revision, :deployed_revision, :location, :start, :finish, :success
  belongs_to :application
  belongs_to :coder
  has_one :deploy_log
  

  
  def self.create_or_update_from_params(provided_params)
    if(!provided_params['appkey'] or !provided_params['capatross_id'] or !provided_params['deployer_email'])
      return nil
    end
    
    if(!(deploy = self.find_by_capatross_id(provided_params['capatross_id'])))

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
    deploy.save!
    
    if(provided_params['deploy_log'])
      deploy_log = DeployLog.find_or_create_by_deploy(deploy)
      deploy_log.update_attribute(:output,provided_params['deploy_log'])
    end
    
    deploy
  end

    
    
      
    
end
