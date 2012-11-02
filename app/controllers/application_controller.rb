# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file

class ApplicationController < ActionController::Base
  protect_from_forgery
  include AuthLib
  before_filter :signin_optional
  helper_method :time_period_to_s
  helper_method :humanize_bytes

  # Takes a period of time in seconds and returns it in human-readable form (down to minutes)
  # code from http://www.postal-code.com/binarycode/2007/04/04/english-friendly-timespan/
  def time_period_to_s(time_period,abbreviated=false,defaultstring='')
   out_str = ''
   interval_array = [ [:weeks, 604800], [:days, 86400], [:hours, 3600], [:minutes, 60], [:seconds, 1] ]
   interval_array.each do |sub|
    if time_period >= sub[1] then
      time_val, time_period = time_period.divmod( sub[1] )
      if(abbreviated)
        name = sub[0].to_s.first
        ( sub[0] != :seconds ? out_str += ", " : out_str += " " ) if out_str != ''
      else
        time_val == 1 ? name = sub[0].to_s.chop : name = sub[0].to_s
        ( sub[0] != :seconds ? out_str += ", " : out_str += " and " ) if out_str != ''
      end
      out_str += time_val.to_i.to_s + " #{name}"
    end
   end
   if(out_str.nil? or out_str.empty?)
     return defaultstring
   else
     return out_str
   end
  end


  # code from: https://github.com/ripienaar/mysql-dump-split
  def humanize_bytes(bytes,defaultstring='')
    if(!bytes.nil? and bytes != 0)
      units = %w{B KB MB GB TB}
      e = (Math.log(bytes)/Math.log(1024)).floor
      s = "%.1f"%(bytes.to_f/1024**e)
      s.sub(/\.?0*$/,units[e])
    else
      defaultstring
    end
  end

end
