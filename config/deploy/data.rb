set :rails_env, 'production'
set :deploy_to, '/services/deploys/'
set :use_delayed_job, false
server 'data.engineering.extension.org', :app, :web, :db, :primary => true