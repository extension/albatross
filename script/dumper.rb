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
  def all_the_things
    load_rails(options[:environment])
    AppDump.daily.each do |appdata|
      puts "Dumping the #{appdata.dbtype} data in #{appdata.dbname} for #{appdata.application.name}..."
      result = appdata.dump(options[:debug])
      if(!result[:success])
        $stderr.puts("Error with #{appdata.application.name} data dump: #{result[:error]}")
      else
        puts "  Saved as #{result[:file]}"
      end
    end
  end

end

DataDumper.start
