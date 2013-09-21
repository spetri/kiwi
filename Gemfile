source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

gem 'mongoid', git: 'https://github.com/mongoid/mongoid.git'

gem 'bson_ext'
gem 'devise', '3.1.0.rc2'

gem 'slim-rails'

group :assets do
  gem 'sass-rails',   '~> 4.0.0'
  gem 'coffee-rails', '~> 4.0.0'
  gem 'ejs'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-ui-rails'
gem 'jquery-rails'
gem 'therubyracer', platforms: :ruby
gem "twitter-bootstrap-rails", :github => "seyhunak/twitter-bootstrap-rails", :branch => "bootstrap3"
gem 'less-rails'

gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'guard'
  gem 'rspec-rails'
  gem 'mongoid-rspec'
  gem "jasminerice", :git => 'https://github.com/bradphelan/jasminerice.git'
  gem 'guard-jasmine'
  gem 'sinon-rails'
  gem 'mailcatcher'
end
