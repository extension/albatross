# encoding: utf-8
# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
module ApplicationHelper
  
  def twitter_alert_class(type)
    baseclass = "alert"
    case type
    when :alert
      "#{baseclass} alert-warning"
    when :error
      "#{baseclass} alert-error"
    when :notice
      "#{baseclass} alert-info"
    when :success
      "#{baseclass} alert-success"
    else
      "#{baseclass} #{type.to_s}"
    end
  end
  
  def nav_item(path,label)
    list_item_class = current_page?(path) ? " class='active'" : ''
    "<li#{list_item_class}>#{link_to(label,path)}</li>".html_safe
  end
  
  
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
      out_str += time_val.to_s + " #{name}"
    end
   end
   if(out_str.nil? or out_str.empty?)
     return defaultstring
   else
     return out_str
   end
  end
  
  
end
