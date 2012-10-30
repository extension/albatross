set :rails_env, 'production'
set :deploy_to, '/services/deploys/'
set :use_delayed_job, true
server 'deploys.extension.org', :app, :web, :db, :primary => true