source 'https://rubygems.org'
gem 'rails', '3.2.22.2'

# all things xml
gem 'nokogiri'

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
  gem 'bootstrap-sass', '~> 3.1.1'
  # wysihtml5 + bootstrap + asset pipeline
  gem 'bootstrap-wysihtml5-rails'
  # replaces glyphicons
  gem 'font-awesome-rails'
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
gem 'capistrano', '~> 2.15.5'
gem 'capatross', :source => 'https://engineering.extension.org/rubygems'


# exception handling for now
gem 'honeybadger'

# background jobs
gem 'sidekiq', '~> 2.17.7'

# slack integration
gem "slack-notifier"

# command line integration
gem 'thor'

# oauth
gem 'doorkeeper'

# cache
gem 'redis-rails'

# html sanitization
gem 'loofah'

# breadcrumbs
gem "breadcrumbs_on_rails"

# log handling
gem "lograge"

# sidekiq web monitoring
gem 'sinatra', :require => nil

# Ruby 2.2 wtf
gem 'test-unit'

group :development do
  # require the powder gem
  gem 'powder'
  gem 'pry'
  gem 'quiet_assets'
  gem 'httplog'

  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
end
