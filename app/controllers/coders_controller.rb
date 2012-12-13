# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class CodersController < ApplicationController

  def show
    @coder = Coder.find(params[:id])
  end


end