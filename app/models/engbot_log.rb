# === COPYRIGHT:
# Copyright (c) 2014 North Carolina State University
# === LICENSE:
# see LICENSE file

class EngbotLog < ActiveRecord::Base

  attr_accessor   :message, :post_to_room
  attr_accessible :slack_channel_id, :slack_channel_name, :slack_user_id, :slack_user_name, :command, :commandtext

  ENGBOT_ACTIONS = ['whatis','help','purpose']

  after_create :parse_commandtext

  def parse_commandtext
    commandterms = self.commandtext.split(/\s+/).compact.uniq.reverse
    # remove nils, duplicates, and reverse it, so we can pop the action off
    action = commandterms.pop
    if(!ENGBOT_ACTIONS.include?(action))
      return self.help
    end

    # check for "room"
    if(commandterms.include?('room'))
      commandterms.reject!{|term| term == 'room'}
      self.post_to_room = true
    else
      self.post_to_room = false
    end

    case action
    when 'whatis'
      return self.whatis(commandterms)
    when 'purpose'
      return self.purpose(commandterms)
    when 'help'
      return self.help
    else
      return self.help
    end
  end


  def whatis(commandterms)
    if(commandterms.blank?)
      return(self.message = 'empty whatis list')
    end

    serverlist = MonitoredServer.where("name IN (#{commandterms.collect{|term| quote_value(term)}.join(',')})")
    if(serverlist.blank?)
      return(self.message = 'no matches found')
    end

    purposes = []
    serverlist.each do |server|
      purposes << "#{server.name} : #{server.purpose}"
    end

    return(self.message = purposes.join("\n"))

  end

  def purpose(commandterms)
    if(commandterms.blank?)
      return(self.message = 'empty purpose list')
    end

    # only going to use the first purpose (well the last since we reverse the terms)
    serverlist = MonitoredServer.where("purpose LIKE ?",'%' + commandterms.first + '%')
    if(serverlist.blank?)
      return(self.message = 'no matches found')
    end

    purposes = []
    serverlist.each do |server|
      purposes << "#{server.name} : #{server.purpose}"
    end

    return(self.message = purposes.join("\n"))
  end

  def help
    helptext = "The /engbot command queries https://engineering.extension.org for information\n"
    helptext += "Available subcommands are:\n"
    helptext += "/engbot whatis servername1 servername2 [...] : returns the purpose for each listed server\n"
    helptext += "  e.g. /engbot whatis jockeysridge dismalswamp"
    helptext += "/engbot purpose search_string : searches the server purpose for search_string and returns all matching records\n"
    helptext += "  e.g. /engbot purpose rails"
    return(self.message = helptext)
  end

end
