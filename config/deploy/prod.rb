set :rails_env, 'production'
set :deploy_to, '/services/engineering/'
set :vhost, 'engineering.extension.org'
server vhost, :app, :web, :db, :primary => true
