# encoding: utf-8
# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
module DashboardHelper

  def where_deployed(deploy)
    if(url = deploy.deployed_to_url)
      "New release to #{url}".html_safe
    else
      "New release of #{deploy.application.name} to #{deploy_location}".html_safe
    end
  end

  def deployed_time(deploy)
     if(deploy.finish.blank?)
       ''
     else
       link_to(deploy.finish.strftime("%B %e, %Y, %l:%M %p %Z"), deploy_path(deploy)).html_safe
     end
  end

end
