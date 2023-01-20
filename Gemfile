# frozen_string_literal: true

source "https://rubygems.org"
ruby '2.6.5'
git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# gem "rails"
gem 'rack'
gem 'sinatra'
gem 'require_all'
gem 'activerecord', '6.1.7.1', require: 'active_record'
gem 'sinatra-activerecord'

group :development do
  gem 'sqlite3'
  gem 'shotgun'
  gem 'pry'
end

group :production do
  gem 'pg'
end

group :development, :production do
  gem 'rake'
end
