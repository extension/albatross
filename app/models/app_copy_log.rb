# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
require 'fileutils'

class AppCopyLog < ActiveRecord::Base
  extend TimeUtils
  serialize :additionaldata
  belongs_to :coder
  belongs_to :app_copy
  has_one :application, through: :app_copy
end