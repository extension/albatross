# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class AppLocation < ActiveRecord::Base
  belongs_to :application
  attr_accessible :application, :application_id, :location, :url, :dbname

  PRODUCTION = 'production'
  DEVELOPMENT = 'development'


end