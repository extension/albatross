set :rails_env, 'production'
set :deploy_to, '/services/engineering/'
server 'dev-engineering.extension.org', :app, :web, :db, :primary => true