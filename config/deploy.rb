set :stages, %w(production development)
set :default_stage, "development"
require 'capistrano/ext/multistage'

task :production do
  set :deploy_to, '/services/deploys/'
  server 'deploys.extension.org', :app, :web, :db, :primary => true
end

task :development do
  set :deploy_to, '/services/deploys/'
  server 'dev.deploys.extension.org', :app, :web, :db, :primary => true
end

require 'capatross'
require "bundler/capistrano"
require "delayed/recipes" 
set :application, "albatross"
set :repository,  "git@github.com:extension/albatross.git"
set :branch, "master"
set :scm, "git"
set :user, "pacecar"
set :use_sudo, false
set :keep_releases, 3
ssh_options[:forward_agent] = true
set :port, 24
#ssh_options[:verbose] = :debug
set :bundle_flags, ''
set :bundle_dir, ''
set :rails_env, "production" #added for delayed job  

before "deploy", "deploy:web:disable"
#after "deploy:update_code", "deploy:bundle_install"
after "deploy:update_code", "deploy:update_maint_msg"
after "deploy:update_code", "deploy:link_and_copy_configs"
after "deploy:update_code", "deploy:cleanup"
after "deploy:update_code", "deploy:compile_assets"
after "deploy", "deploy:web:enable"
# delayed job
after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"

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
  
  # compile assets
  desc "runs bundle exec rake assets:precompile"
  task :compile_assets do
    run "cd #{release_path} && bundle exec rake assets:precompile"
  end
  
  desc "Update maintenance mode page/graphics (valid after an update code invocation)"
  task :update_maint_msg, :roles => :app do
     invoke_command "cp -f #{release_path}/public/maintenancemessage.html #{shared_path}/system/maintenancemessage.html"
  end
  
  # Link up various configs (valid after an update code invocation)
  task :link_and_copy_configs, :roles => :app do
    run <<-CMD
    rm -rf #{release_path}/config/database.yml && 
    ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
    ln -nfs #{shared_path}/config/settings.local.yml #{release_path}/config/settings.local.yml &&
    ln -nfs #{shared_path}/omniauth #{release_path}/tmp/omniauth
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
      invoke_command "touch #{shared_path}/system/maintenancemode"
    end
  
    desc "Remove Apache from maintenancemode by removing the system/maintenancemode file"
    task :enable, :roles => :app do
      invoke_command "rm -f #{shared_path}/system/maintenancemode"
    end
    
  end  
end

