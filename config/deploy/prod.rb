set :rails_env, 'production'
set :deploy_to, '/services/deploys/'
server 'deploys.extension.org', :app, :web, :db, :primary => true