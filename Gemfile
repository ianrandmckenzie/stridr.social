source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '2.4.2'
# Dot Env
# gem 'dotenv-rails', groups: [:development, :test]
gem 'dotenv-rails', :require => 'dotenv/rails-now'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.1'
# Use postgresql as the database for Active Record
# group :production do
gem 'pg'
# end
# Use Puma as the app server
gem 'puma', '~> 3.0'
# OmniAuth + Strategies
gem 'omniauth', '~> 1.6.1'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth-instagram'
gem 'omniauth-spotify'
gem 'omniauth-twitch'
gem 'omniauth-reddit', github: 'ianrandmckenzie/omniauth-reddit'
gem 'omniauth-deviantart', '~> 0.0.1', github: 'klpl/omniauth-deviantart' # klpl fixes an issue from the unmaintained gem
gem 'rest-client'
# 'omniauth-pinterest' is part of Pinterest gem. See REST API GEMS below
gem 'omniauth-tumblr'
gem 'omniauth-twitter'
# Use SCSS for stylesheets
gem 'bootstrap-sass', '~> 3.3.6'
gem 'font-awesome-sass', '~> 4.7.0'
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-turbolinks'

# Kaminari pager for dynamic loading
gem 'kaminari'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.2'
# Sidekiq for background workers
gem 'sidekiq'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'
# Use Devise Authentication/Authorization
gem 'devise'
# Acts as Votable (Likes system)
gem 'acts_as_votable', '~> 0.10.0'

# ------ START REST API GEMS ------ #
# Facebook REST API Gem
gem 'koala'
# Google / YouTube REST API Gem
gem 'yt', '~> 0.28.0'
# gem 'google-api-client', '~> 0.11'
# Pinterest REST API Gem w/ OmniAuth
gem 'pinterest-api'
# Official Tumblr REST API Gem
# gem 'tumblr_client'
gem 'tumblr_client', github: 'drusepth/tumblr_client' # Using drusepth's fork for Faraday dependency issue
# ------ END REST API GEMS ------ #
gem 'social-share-button'
# Image storing
gem "paperclip", "~> 5.0.0"
gem 'aws-sdk', '~> 2.3'

# engtagger for classifying words
gem 'engtagger'

gem 'imgkit'
gem 'wkhtmltoimage-binary'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'faker'
  gem 'thin'
end

group :development do
  # gem 'sqlite3'
  gem 'rails_real_favicon'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
