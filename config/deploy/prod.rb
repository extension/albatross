set :rails_env, 'production'
set :deploy_to, '/services/engineering/'
set :vhost, 'engineering.awsi.extension.org'
server vhost, :app, :web, :db, :primary => true
