# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
class Servers < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :signin_required


  def index
    @serverlist = MonitoredServer.active.all
  end

end
