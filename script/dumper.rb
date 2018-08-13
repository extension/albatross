#!/usr/bin/env ruby
require 'rubygems'
require 'thor'
require 'benchmark'

class DataDumper < Thor
  include Thor::Actions

  # these are not the tasks that you seek
  no_tasks do
    # load rails based on environment

    def load_rails(environment)
      if !ENV["RAILS_ENV"] || ENV["RAILS_ENV"] == ""
        ENV["RAILS_ENV"] = environment
      end
      require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
    end

  end

  desc "all_the_things", "Dump all known databases"
  method_option :environment,:default => 'production', :aliases => "-e", :desc => "Rails environment"
  method_option :debug,:default => false, :aliases => "-d", :desc => "Debug"
  method_option :announce,:default => false, :aliases => "-a", :desc => "Announce"
  def all_the_things
    load_rails(options[:environment])
    AppDump.nonsnapshot.each do |appdump|
      puts "Dumping the #{appdump.dbtype} data in #{appdump.dbname} for #{appdump.application.name}..."
      dump_log = appdump.dump({debug: options[:debug], announce: options[:announce]})
      if(!dump_log.success?)
        # ignore mysql password error
        if(dump_log.additionaldata[:error]) != '[Warning] Using a password on the command line interface can be insecure.'
          $stderr.puts("Error with #{appdump.application.name} data dump: #{dump_log.additionaldata[:error]}")
        end
      else
        puts "  Saved as #{dump_log.additionaldata[:file]}"
      end
    end
  end

  desc "daily", "Dump all known daily databases"
  method_option :environment,:default => 'production', :aliases => "-e", :desc => "Rails environment"
  method_option :debug,:default => false, :aliases => "-d", :desc => "Debug"
  method_option :announce,:default => false, :aliases => "-a", :desc => "Announce"
  def daily
    load_rails(options[:environment])
    AppDump.nonsnapshot.daily.each do |appdump|
      puts "Dumping the #{appdump.dbtype} data in #{appdump.dbname} for #{appdump.application.name}..."
      dump_log = appdump.dump({debug: options[:debug], announce: options[:announce]})
      if(!dump_log.success?)
        # ignore mysql password error
        if(dump_log.additionaldata[:error]) != '[Warning] Using a password on the command line interface can be insecure.'
          $stderr.puts("Error with #{appdump.application.name} data dump: #{dump_log.additionaldata[:error]}")
        end
      else
        puts "  Saved as #{dump_log.additionaldata[:file]}"
      end
    end
  end

  desc "showdaily", "Show the list of daily dump databases"
  method_option :environment,:default => 'production', :aliases => "-e", :desc => "Rails environment"
  def showdaily
    load_rails(options[:environment])
    AppDump.nonsnapshot.daily.each do |appdump|
      puts "#{appdump.application.name} : #{appdump.dbname} (#{appdump.dbtype})"
    end
  end

end

DataDumper.start
