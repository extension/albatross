set :rails_env, 'production'
set :deploy_to, '/services/engineering/'
set :vhost, 'engineering.extension.org'
set :deploy_server, 'engineering.awsi.extension.org'
server deploy_server, :app, :web, :db, :primary => true
