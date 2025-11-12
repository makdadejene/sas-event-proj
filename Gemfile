source "https://rubygems.org"

ruby "3.3.0"

# -----------------------------
# Core Rails + DB + Server
# -----------------------------
gem "rails", "~> 7.1.3"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "sprockets-rails"
gem "jbuilder"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[windows jruby]

# -----------------------------
# Front-end / Hotwire
# -----------------------------
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "omniauth-rails_csrf_protection"

# -----------------------------
# Authentication
# -----------------------------
gem "devise"
gem "omniauth-google-oauth2"

# -----------------------------
# Environment Variables
# -----------------------------
gem "dotenv-rails", "~> 3.1"

# -----------------------------
# Development / Test
# -----------------------------
group :development, :test do
  gem "rspec-rails"
  gem "rails-controller-testing"
  gem "debug", platforms: %i[mri windows]
  gem "cucumber-rails", require: false
  gem "capybara"
  gem "database_cleaner-active_record"
end

# -----------------------------
# Test only
# -----------------------------
group :test do
  gem "simplecov", require: false
  gem "selenium-webdriver"
  gem 'shoulda-matchers', '~> 5.0'
end

# -----------------------------
# Development only
# -----------------------------
group :development do
  gem "web-console"
end
