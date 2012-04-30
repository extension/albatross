# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class DeployLog < ActiveRecord::Base
  belongs_to :deploy
  
  
  def self.find_or_create_by_deploy(deploy)
    if(!(deploy_log = self.find_by_deploy_id(deploy.id)))
      deploy_log = self.create(deploy: deploy)
    end
    deploy_log
  end
  
end
