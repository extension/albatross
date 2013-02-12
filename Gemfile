source 'https://rubygems.org'
source 'http://systems.extension.org/rubygems/'

gem 'rails', '3.2.12'


# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# storage
gem 'mysql2'



# Gems used only for assets and not required
# in production environments by default.
# speed up sppppppprooooockets
gem 'turbo-sprockets-rails3'
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
  # files for bootstrap-in-asset-pipeline integration
  gem 'anjlab-bootstrap-rails', '>= 2.0', :require => 'bootstrap-rails'
  # wysihtml5 + bootstrap + asset pipeline
  gem 'bootstrap-wysihtml5-rails'
end

# server settings
gem "rails_config"

# authentication
gem 'omniauth', "~> 1.0"
gem 'omniauth-openid'

# jquery magick
gem 'jquery-rails'

# pagination
gem 'kaminari'

# Deploy with Capistrano
gem 'capistrano'
gem 'capatross'

# exception handling for now
gem 'airbrake'

# background jobs
gem 'delayed_job_active_record'
gem 'daemons'

# campfire integration
gem "tinder", "~> 1.9.0"

# command line integration
gem 'thor'

# memcached
gem 'dalli'

# html sanitization
gem 'loofah'

group :development do
  # require the powder gem
  gem 'powder'
  gem 'pry'
  gem 'quiet_assets'
end
