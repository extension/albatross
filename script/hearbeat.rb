#!/usr/bin/env ruby
require 'rubygems'
require 'thor'
require 'benchmark'

class Heartbeat < Thor
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

  desc "hodor", "Post a Slack Hodor Heartbeat"
  method_option :environment,:default => 'production', :aliases => "-e", :desc => "Rails environment"
  def hodor
    load_rails(options[:environment])
    SlackNotification.delay.hodor
  end

end

Heartbeat.start
