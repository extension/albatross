set :rails_env, 'production'
set :deploy_to, '/services/engineering/'
if(branch = ENV['BRANCH'])
  set :branch, branch
else
  set :branch, 'master'
end
set :vhost, 'dev-engineering.extension.org'
server vhost, :app, :web, :db, :primary => true
