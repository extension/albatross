# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
class NotificationsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :signin_required  
  
  
  def index
    @applist = Application.all
  end
  
  
end