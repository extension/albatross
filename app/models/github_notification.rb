# === COPYRIGHT:
# Copyright (c) 2014 North Carolina State University
# === LICENSE:
# see LICENSE file

class GithubNotification < ActiveRecord::Base
  serialize :payload

  belongs_to :application
  belongs_to :coder

  attr_accessible :application, :coder, :payload, :branch


  def self.create_from_params(provided_params)
    if(!provided_params['ref'] or !provided_params['pusher'] or !provided_params['repository'] or !provided_params['repository']['name'])
      return nil
    end

    if(!(application = Application.find_by_github_reponame(provided_params['repository']['name'])))
      return nil
    end

    gn = self.new(application: application)

    if(coder = Coder.where(github_name: provided_params['pusher']['name']).first)
      gn.coder = coder
    end


    match = provided_params['ref'].match(%r{^refs/heads/(?<branch>\w+)})
    if(match and match['branch'])
      gn.branch = match['branch']
    end

    gn.payload = provided_params
    gn.save!



    # notifications
    # TODO


    gn
  end

end
