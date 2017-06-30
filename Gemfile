source 'https://rubygems.org'

ruby "2.3.1"

gem 'bundler'
gem "rails", "3.2.22.2"
# gem "mysql2", "~> 0.3.11" # this gem works better with utf-8
gem "mysql2", "~> 0.3.21" # this gem works better with utf-8

gem "json"
gem "jquery-rails", "3.1.2"
gem "devise", "~> 2.0.4" # user authentication
gem "cancan", "~> 1.6.8" # user authorization
gem "formtastic", "~> 2.1.1" # create forms easier
gem "formtastic-bootstrap", :git => "https://github.com/cgunther/formtastic-bootstrap.git", :branch => "bootstrap-2"


gem 'fancybox-rails', '~> 0.3.0' # use fancybox js


gem 'omniauth' # to login via facebook
gem 'omniauth-facebook' # to login via facebook
gem 'globalize3', '~> 0.3.1' # internationalization
gem "psych", "2.0.13" # yaml parser - default psych in rails has issues
gem "will_paginate", "~> 3.0.3" # add paging to long lists
gem "gon", "5.2.3" # push data into js
gem "dynamic_form", "~> 1.1.4" # to see form error messages
gem "i18n-js", "~> 2.1.2" # to show translations in javascript
gem "paperclip", "~> 3.4.0" # to upload files
gem "capistrano", "~> 2.12.0" # to deploy to server
gem "exception_notification", "2.5.2" # send an email when exception occurs



gem 'nokogiri', '~> 1.6', '>= 1.6.6.2' # read xml file
gem "paper_trail", "~> 2.7.0" # keep audit log of all transactions


gem 'active_attr', '~> 0.9.0' # to create tabless models; using for contact form
gem 'whenever', '~> 0.9.7' # schedule cron jobs
gem "impressionist", "1.4.13" # keep track of views



gem "gabba", "~> 1.0.1" # send to google analytics from server side
gem 'rack-utf8_sanitizer', '~> 1.3', '>= 1.3.2' # prevent invalid encoding error

gem 'test-unit', '~> 3.0' # use rails c on server

gem 'dotenv-rails', '~> 2.2', '>= 2.2.1' # environment variables

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem "sass-rails", "3.2.6"
  gem "coffee-rails", "~> 3.2.2"
  gem "uglifier", ">= 1.0.3"
  gem 'therubyracer'
  gem 'less-rails', "~> 2.6.0"
  gem "twitter-bootstrap-rails", "~> 2.2.8"
  gem 'jquery-ui-rails', '~> 5.0', '>= 5.0.5'
  gem 'jquery-datatables-rails', '~> 1.12', '>= 1.12.2'
end

group :development do
#	gem "mailcatcher", "0.5.5" # small smtp server for dev, http://mailcatcher.me/
#	gem "wkhtmltopdf-binary", "~> 0.9.5.3" # web kit that takes html and converts to pdf
  gem 'rb-inotify', '~> 0.9.7' # rails dev boost needs this
  gem 'rails-dev-boost', :git => 'git://github.com/thedarkone/rails-dev-boost.git' # speed up loading page in dev mode
end

group :staging, :production do
  gem 'unicorn', '~> 5.2.0' # http server
end

