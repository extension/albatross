# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class AppsController < ApplicationController

  def show
    @application = Application.find(params[:id])
  end

end