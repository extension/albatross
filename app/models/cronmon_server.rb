# === COPYRIGHT:
# Copyright (c) North Carolina State University
# === LICENSE:
# see LICENSE file

class CronmonServer < ActiveRecord::Base

  validates :name, :presence => true, :uniqueness => true 
  
  has_many :cronmons
  has_one :oauth_application, class_name: 'Doorkeeper::Application', as: :owner, dependent: :destroy

  def self.register(name,reset_oauth_application=false)
  	if(cs = self.where(name: name).first)
      if(reset_oauth_application)
        if(oa = cs.oauth_application)
          oa.destroy
          cs.create_oauth_application(name: "cronmon-#{cs.name}", redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
        else
          cs.create_oauth_application(name: "cronmon-#{cs.name}", redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
        end
      end          
  	else
      if(cs = create(name: name))
        cs.create_oauth_application(name: "cronmon-#{cs.name}", redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
      end
    end
    cs
  end

  def find_or_create_cronmon_by_label(label)
    if(!cronmon = self.cronmons.where(label: label).first)
      cronmon = self.cronmons.create(label: label)
    end
    cronmon
  end

end