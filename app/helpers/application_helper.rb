# encoding: utf-8
# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
module ApplicationHelper

  def twitter_alert_class(type)
    baseclass = "alert"
    case type
    when :alert
      "#{baseclass} alert-warning"
    when :error
      "#{baseclass} alert-error"
    when :notice
      "#{baseclass} alert-info"
    when :success
      "#{baseclass} alert-success"
    else
      "#{baseclass} #{type.to_s}"
    end
  end

  def nav_item(path,label)
    list_item_class = current_page?(path) ? " class='active'" : ''
    "<li#{list_item_class}>#{link_to(label,path)}</li>".html_safe
  end

  def github_url_for_deploy(deploy)
    baseurl = deploy.application.github_url
    if(deploy.deployed_revision != deploy.previous_revision)
      "#{baseurl}/compare/#{deploy.previous_revision}...#{deploy.deployed_revision}"
    else
      "#{baseurl}/commit/#{deploy.deployed_revision}"
    end
  end

end
