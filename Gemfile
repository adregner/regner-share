source :rubygems

# Server requirements
# gem 'thin' # or mongrel
# gem 'trinidad', :platform => 'jruby'

# Project requirements
gem 'rake'
gem 'sinatra-flash', :require => 'sinatra/flash'

# Component requirements
gem 'tilt', '1.3.3'
gem 'therubyracer'
gem 'rack-less'
gem 'rack-thumb'
gem 'less'
gem 'haml'
gem 'mongo'
gem 'mimemagic'
gem 'mongoid', '>3'
gem 'bson_ext', :require => "mongo"
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-google-oauth2'
gem 'omniauth-facebook', '1.4.0'
gem 'omniauth-github'
gem 'omniauth-netflix'
gem 'omniauth-ebay'
gem 'omniauth-dropbox'
require 'digest/md5'

# Test requirements

# Padrino Stable Gem
gem 'padrino', '0.10.7'

group :production do
  gem 'unicorn'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
end
