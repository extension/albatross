set :rails_env, 'production'
set :deploy_to, '/services/deploys/'
server 'dev.engineering.extension.org', :app, :web, :db, :primary => true