# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class CoderEmail < ActiveRecord::Base
  belongs_to :coder
  attr_accessible :coder, :coder_id, :email
end