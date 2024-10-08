source 'https://rubygems.org/'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '>= 3.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.1.5'
# we can not using rack 3 as it change HTTP header like 'Authorization' into small cap 'authorization', so it will break a lot of client application login
gem 'rack', '< 3'
gem 'rails-i18n'
# `config/initializers/mail_starttls_patch.rb` has also been patched to
# fix STARTTLS handling until https://github.com/mikel/mail/pull/1536 is
# released.
gem 'mail', '= 2.8.1'

# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.7'

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
gem 'pagy'

gem 'terser'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.4.4'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'

gem 'devise'
# bundle config local.devise-jwt /Users/$(whoami)/git/oss/devise-jwt/
gem 'devise-jwt', git: 'https://git.thape.com.cn/rails/devise-jwt.git', branch: :main
gem 'dry-auto_inject', '~> 1.0.1'
gem 'digest', '~> 3.2'

# bundle config local.doorkeeper /Users/$(whoami)/git/oss/doorkeeper/
gem 'doorkeeper', git: 'https://github.com/Eric-Guo/doorkeeper', branch: :main
# bundle config local.doorkeeper-openid_connect /Users/$(whoami)/git/oss/doorkeeper-openid_connect/
gem 'doorkeeper-openid_connect', git: 'https://github.com/thape-cn/doorkeeper-openid_connect', branch: :master

# bundle config local.devise_ldap_authenticatable /Users/guochunzhong/git/oss/devise_ldap_authenticatable/
gem 'devise_ldap_authenticatable', git: 'https://github.com/Eric-Guo/devise_ldap_authenticatable', branch: :search_by_ldap_attr

gem 'pundit'

# bundle config local.saml_idp /Users/$(whoami)/git/sso/saml_idp/
gem 'saml_idp', git: 'https://github.com/thape-cn/saml_idp', branch: :oauth2id
# Encrypted Assertions require the xmlenc gem in saml_idp
gem 'xmlenc'

# bundle config local.wechat /Users/$(whoami)/git/oss/wechat/
gem 'wechat', git: 'https://github.com/Eric-Guo/wechat', branch: :main
gem 'nokogiri', '~> 1.17.2'
gem 'psych', '~> 3.3.4'

gem 'ipip-fast'

gem 'gitlab'

# bundle config local.yxt-api /Users/guochunzhong/git/sso/yxt-api/
gem 'yxt-api', git: 'https://github.com/thape-cn/yxt-api', branch: :master

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

gem 'whenever', require: false
gem 'net-sftp', require: false

# Ruby 3.1 removed as default gems.
gem 'net-smtp'
gem 'net-imap'
gem 'net-pop'

# To import the excel
gem 'roo', require: false

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.18.4', require: false

group :production, :staging do
  gem 'dalli'
  gem 'minitest'
end

group :development, :test do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 4.2.1'

  # Call 'debugger' anywhere in the code to stop execution and get a debugger console
  gem 'debug'

  gem 'ffaker'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console'

  gem 'listen'

  gem 'capistrano3-puma', '~> 6.0'
  gem 'capistrano-rails'
  gem 'capistrano-yarn'
  gem 'capistrano-rbenv'
  gem 'ed25519'
  gem 'bcrypt_pbkdf'

  # Support cursor / vs code
  gem "ruby-lsp", require: false
  gem "ruby-lsp-rails", require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.40'
  gem 'selenium-webdriver', '= 4.26.0'
end

group :ci do
  gem 'minitest-ci'
  gem 'simplecov', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
