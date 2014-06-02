source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.0.3'
gem 'newrelic_rpm'

gem 'mongoid', '4.0.0.beta1'
gem 'bson_ext'
gem 'mongoid-tree', branch: 'mongoid-4.0'

gem 'devise', '3.1.0.rc2'
gem 'slim-rails'
gem 'omniauth-facebook', '1.4.0'
gem 'omniauth-twitter'

gem 'whenever'
gem 'cancan'

#Server
gem 'puma'

gem 'mailchimp-api', require: 'mailchimp'

group :assets do
  gem 'sass-rails',   '~> 4.0.0'
  gem 'coffee-rails', '~> 4.0.0'
  gem 'ejs'
  gem 'eco'
  gem 'uglifier', '>= 1.0.3'
end
gem 'bootstrap-sass', '~> 3.0.2.0'
gem 'font-awesome-rails'

gem 'jquery-ui-rails'
gem 'jquery-rails'
gem 'therubyracer', platforms: :ruby
gem 'less-rails'

gem 'jbuilder', '~> 1.2'
gem 'paperclip', '~> 3.0'
gem 'aws-sdk'
gem 'mongoid-paperclip', :require => 'mongoid_paperclip'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'mina'
  gem 'hipchat'
  gem 'timecop'
  gem 'debugger', '1.6.6'
  gem 'guard'
  gem 'guard-spork'
  gem 'spork-rails', :github => 'sporkrb/spork-rails'
  gem 'guard-rspec'
  gem 'rspec-rails'
  gem 'mongoid-rspec'
  gem "jasminerice", :git => 'https://github.com/bradphelan/jasminerice.git'
  gem 'guard-jasmine'
  gem 'sinon-rails'
  gem 'mailcatcher'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
end
