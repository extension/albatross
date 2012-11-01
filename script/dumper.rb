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
    AppDump.each do |appdump|
      puts "Dumping the #{appdump.dbtype} data in #{appdump.dbname} for #{appdump.application.name}..."
      dump_log = appdump.dump({debug: options[:debug], announce: options[:announce]})
      if(!dump_log.success?)
        $stderr.puts("Error with #{appdump.application.name} data dump: #{dump_log.additionaldata[:error]}")
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
    AppDump.daily.each do |appdump|
      puts "Dumping the #{appdump.dbtype} data in #{appdump.dbname} for #{appdump.application.name}..."
      dump_log = appdump.dump({debug: options[:debug], announce: options[:announce]})
      if(!dump_log.success?)
        $stderr.puts("Error with #{appdump.application.name} data dump: #{dump_log.additionaldata[:error]}")
      else
        puts "  Saved as #{dump_log.additionaldata[:file]}"
      end
    end
  end

  desc "all_the_things", "Dump the database for a specific application"
  method_option :environment,:default => 'production', :aliases => "-e", :desc => "Rails environment"
  method_option :name, :aliases => "-n", :desc => "Application name", required: true
  method_option :dbtype,:default => 'production', :aliases => "-t", :desc => "Database type"
  method_option :announce,:default => false, :aliases => "-a", :desc => "Announce"
  def application
    load_rails(options[:environment])
    application = Application.find_by_name(options[:name])
    if(!application)
      puts "Unable to find the specified application"
    end
    appdump = application.app_dumps.where(dbtype: options[:dbtype]).first
    if(!application)
      puts "No dump specification exists for that dbtype and application"
    end

    puts "Dumping the #{appdump.dbtype} data in #{appdump.dbname} for #{appdump.application.name}..."
    dump_log = appdump.dump({debug: options[:debug], announce: options[:announce]})
    if(!dump_log.success?)
      $stderr.puts("Error with #{appdump.application.name} data dump: #{dump_log.additionaldata[:error]}")
    else
      puts "  Saved as #{dump_log.additionaldata[:file]}"
    end
  end

end

DataDumper.start
