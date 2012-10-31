# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
require 'fileutils'

class AppDumpLog < ActiveRecord::Base
  serialize :additionaldata
  belongs_to :app_dump

end