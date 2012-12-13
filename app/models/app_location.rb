# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class AppLocation < ActiveRecord::Base
  belongs_to :application
  attr_accessible :application, :application_id, :location, :url, :dbname
  has_many :deploys

  PRODUCTION = 'production'
  DEVELOPMENT = 'development'

  scope :production, where(location: 'production')


  def latest_deploy
    self.deploys.order('finish DESC').first
  end

  def display_url
    begin
      uri = URI.parse(self.url)
      uri.host
    rescue
      self.url
    end
  end

end