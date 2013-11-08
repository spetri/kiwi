source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

gem 'mongoid', git: 'https://github.com/mongoid/mongoid.git', :ref => 'b84b811d47778b9d9f1a6ebc5e084aac7b9c0b63'

gem 'bson_ext'
gem 'devise', '3.1.0.rc2'
gem 'slim-rails'
gem 'omniauth-facebook', '1.4.0'
gem 'omniauth-twitter'

group :assets do
  gem 'sass-rails',   '~> 4.0.0'
  gem 'coffee-rails', '~> 4.0.0'
  gem 'ejs'
  gem 'eco'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-ui-rails'
gem 'jquery-rails'
gem 'therubyracer', platforms: :ruby
gem "twitter-bootstrap-rails", :github => "seyhunak/twitter-bootstrap-rails", :branch => "bootstrap3"
gem 'less-rails'

gem 'jbuilder', '~> 1.2'
gem 'paperclip', '~> 3.0'
gem 'mongoid-paperclip', :require => 'mongoid_paperclip'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'debugger'
  gem 'guard'
  gem 'rspec-rails'
  gem 'mongoid-rspec'
  gem "jasminerice", :git => 'https://github.com/bradphelan/jasminerice.git'
  gem 'guard-jasmine'
  gem 'sinon-rails'
  gem 'mailcatcher'
end
