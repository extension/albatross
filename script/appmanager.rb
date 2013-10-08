#!/usr/bin/env ruby
require 'rubygems'
require 'thor'
require 'benchmark'

class AppManager < Thor
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

  desc "new_application", "Add a new application"
  method_option :environment,:default => 'production', :aliases => "-e", :desc => "Rails environment"
  def new_application
    load_rails(options[:environment])
    has_valid_appname = false
    while !has_valid_appname
      application_name = ask("Application name?").downcase
      if(!application_name.blank?)
        if(app = Application.find_by_name(application_name))
          say("An application with that name already exists",:red)
        else
          has_valid_appname = true
        end
      else
        say("The application name cannot be blank",:red)
      end
    end

    github_repository = ask("GitHub repository (relative to https://github.com/extension)?").downcase
    github_url = "https://github.com/extension/#{github_repository}" if(!github_repository.blank?)

    say("Leave URLs and databases blank if not relevant at this time:")
    production_url = ask("Production URL?").downcase
    production_database = ask("Production Database?").downcase

    dev_url = ask("Demo URL?").downcase
    dev_database = ask("Demo Database?").downcase

    this_app = Application.create(name: application_name, github_url: github_url)
    if(this_app.present? and this_app.valid?)
      
      # production app_location
      if(!production_url.blank? and !production_database.blank?)
        production_location = AppLocation.create(application_id: this_app.id, location: 'production', url: production_url, dbname: production_database)
      end

      # development app_location
      if(!dev_url.blank? and !dev_database.blank?)
        development_location = AppLocation.create(application_id: this_app.id, location: 'development', url: dev_url, dbname: dev_database)
      end

      # dump production db?
      if(production_location.present? and production_location.valid?)
        create_production_dump = yes?("Dump production database?")
        if(create_production_dump)
          production_dump_daily = yes?("Dump production database daily?")
          production_dump = AppDump.create(dbtype: 'production', dbname: production_location.dbname, application_id: this_app.id, app_location_id: production_location.id, daily: production_dump_daily)
        end
      end

      # dump development db?
      if(development_location.present? and development_location.valid?)
        create_development_dump = yes?("Dump development database?")
        if(create_development_dump)
          development_dump_daily = yes?("Dump development database daily?")
          development_dump = AppDump.create(dbtype: 'development', dbname: development_location.dbname, application_id: this_app.id, app_location_id: development_location.id, daily: development_dump_daily)
        end
      end

      puts "Created #{this_app.name} application. Application Key: #{this_app.appkey}"
    else
      puts "Unable to create application."
    end
  end


end

AppManager.start
