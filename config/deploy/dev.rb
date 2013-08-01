set :rails_env, 'production'
set :deploy_to, '/services/engineering/'
if(branch = ENV['BRANCH'])
  set :branch, branch
else
  set :branch, 'development'
end
server 'dev-engineering.extension.org', :app, :web, :db, :primary => true