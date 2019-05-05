source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '>= 2.7.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.4'
gem 'rails-i18n'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Thape using mysql as production
gem 'mysql2'
# Use Oracle to fetch NC data
gem 'activerecord-oracle_enhanced-adapter'
gem 'ruby-oci8'

# Use Puma as the app server
gem 'puma'
# Use jquery as the JavaScript library
gem 'jquery-rails'

gem 'ajax-datatables-rails'

# Use SCSS for stylesheets
gem 'sassc-rails'
gem 'sprockets'

# Host ourself instead of relay on CDN
gem 'font-awesome-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'

gem 'devise'
gem 'devise-jwt'
# bundle config local.doorkeeper /Users/guochunzhong/git/oss/doorkeeper/
gem 'doorkeeper', git: 'https://e.coding.net/sew/doorkeeper.git', branch: :main
# bundle config local.doorkeeper-openid_connect /Users/guochunzhong/git/oss/doorkeeper-openid_connect/
gem 'doorkeeper-openid_connect', git: 'https://github.com/thape-cn/doorkeeper-openid_connect', branch: :master

# bundle config local.devise_ldap_authenticatable /Users/guochunzhong/git/oss/devise_ldap_authenticatable/
gem 'devise_ldap_authenticatable', git: 'https://github.com/Eric-Guo/devise_ldap_authenticatable', branch: :search_by_ldap_attr

gem 'pundit'

# bundle config local.saml_idp /Users/guochunzhong/git/sso/saml_idp/
gem 'saml_idp', git: 'https://github.com/thape-cn/saml_idp', branch: :oauth2id
# Encrypted Assertions require the xmlenc gem in saml_idp
gem 'xmlenc'

# bundle config local.wechat /Users/guochunzhong/git/oss/wechat/
gem 'wechat', git: 'https://github.com/Eric-Guo/wechat', branch: :main

gem 'ipip-fast'

# bundle config local.yxt-api /Users/guochunzhong/git/sso/yxt-api/
gem 'yxt-api', git: 'https://github.com/thape-cn/yxt-api', branch: :master

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

gem 'whenever', require: false

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :production, :staging do
  gem 'dalli'
  gem 'minitest'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  gem 'ffaker'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console'

  gem 'listen'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'

  gem 'capistrano3-puma'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

group :ci do
  gem 'minitest-ci'
  gem 'simplecov', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
