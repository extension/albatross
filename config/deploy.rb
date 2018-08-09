set :stages, %w(prod)
set :default_stage, "prod"
require 'capistrano/ext/multistage'
require 'capatross'
require "bundler/capistrano"
require './config/boot'

set :application, "albatross"
set :repository,  "git@github.com:extension/albatross.git"
set :branch, "master"
set :scm, "git"
set :user, "pacecar"
set :gateway, 'deploy.extension.org'
set :keep_releases, 3
ssh_options[:forward_agent] = true
set :port, 22
#ssh_options[:verbose] = :debug
set :bundle_flags, '--deployment --binstubs'
set :use_sudo, false
set :rails_env, "production" #added for delayed job


before "deploy", "deploy:web:disable"
before "deploy", "sidekiq:stop"
after "deploy:update_code", "deploy:link_and_copy_configs"
after "deploy:update_code", "deploy:cleanup"
after "deploy", "sidekiq:start"
after "deploy", "deploy:web:enable"

namespace :deploy do

  desc "Deploy the #{application} application with migrations"
  task :default, :roles => :app do

    # Invoke deployment with migrations
    deploy.migrations
  end

  # Override default restart task
  desc "Restart passenger"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  # bundle installation in the system-wide gemset
  desc "runs bundle update"
  task :bundle_install do
    run "cd #{release_path} && bundle install"
  end

  # Link up various configs (valid after an update code invocation)
  task :link_and_copy_configs, :roles => :app do
    run <<-CMD
    rm -rf #{release_path}/config/database.yml &&
    ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
    ln -nfs #{shared_path}/config/settings.local.yml #{release_path}/config/settings.local.yml &&
    ln -nfs #{shared_path}/config/honeybadger.yml #{release_path}/config/honeybadger.yml &&
    ln -nfs #{shared_path}/repositories #{release_path} &&
    ln -nfs #{shared_path}/tmpcache    #{release_path}/tmp/cache &&
    ln -nfs #{shared_path}/tmpauth #{release_path}/tmp/auth
    CMD
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end


  # Override default web enable/disable tasks
  namespace :web do

    desc "Put Apache in maintenancemode by touching the system/maintenancemode file"
    task :disable, :roles => :app do
      invoke_command "touch /services/maintenance/#{vhost}.maintenancemode"
    end

    desc "Remove Apache from maintenancemode by removing the system/maintenancemode file"
    task :enable, :roles => :app do
      invoke_command "rm -f /services/maintenance/#{vhost}.maintenancemode"
    end

  end
end

namespace :sidekiq do
  desc 'Stop sidekiq'
  task 'stop', :roles => :app do
    invoke_command 'service sidekiq stop', via: 'sudo'
  end

  desc 'Start sidekiq'
  task 'start', :roles => :app do
    invoke_command 'service sidekiq start', via: 'sudo'
  end

  desc 'Restart sidekiq'
  task 'restart', :roles => :app do
    stop
    start
  end
end
