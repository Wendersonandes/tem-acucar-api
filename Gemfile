source "https://rubygems.org"
ruby "2.3.0"

gem "multi_json"
gem "oj"
gem "pg"
gem "pliny", "~> 0.14"
gem "pry"
gem "puma", "~> 2.10"
gem "rack-ssl"
gem "rack-timeout", "~> 0.3"
gem "rake"
gem "rollbar", require: "rollbar/middleware/sinatra"
gem "sequel", "~> 4.16"
gem "sequel-paranoid"
gem "sequel_pg", "~> 1.6", require: "sequel"
gem "sinatra", "~> 1.4", require: "sinatra/base"
gem "sinatra-contrib", require: ["sinatra/namespace", "sinatra/reloader"]
gem "sinatra-router"
gem "sucker_punch"
gem "committee"
gem "bcrypt"
gem "rest-client"
gem "geocoder"
gem "sequel-geocoder", github: "binarypaladin/sequel-geocoder", ref: "625fe1704261634eca2620e9da5ccaa27b34cae4"
gem "mandrill-api", require: "mandrill"
gem 'state_machine'

group :development, :test do
  gem "pry-byebug"
end

group :test do
  gem "simplecov", require: false
  gem "database_cleaner"
  gem "dotenv"
  gem "rack-test"
  gem "rspec"
end
