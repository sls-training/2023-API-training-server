# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'rails', '~> 7.0.5'

gem 'active_storage_validations', '~> 1.0.4'
gem 'alba', '~> 2.3'
gem 'bcrypt', '~> 3.1.18'
gem 'bootsnap', require: false
gem 'pg', '~> 1.1'
gem 'problem_details-rails', '~> 0.2.3'
gem 'puma', '~> 6.3'

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem 'brakeman', '~> 6.0', require: false
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'faker', '~> 3.2'
  gem 'katakata_irb', github: 'tompng/katakata_irb', require: false
  gem 'rbs_rails', '~> 0.12.0', require: false

  gem 'factory_bot_rails', '~> 6.2'
  gem 'rspec-mocks', '~> 3.12.5'
  gem 'rspec-rails', '~> 6.0.2'

  gem 'rubocop', '~> 1.51', require: false
  gem 'rubocop-factory_bot', '~> 2.23.1', require: false
  gem 'rubocop-performance', '~> 1.18', require: false
  gem 'rubocop-rails', '~> 2.19.1', require: false
  gem 'rubocop-rspec', '~> 2.22', require: false

  github 'timedia/styleguide', glob: 'ruby/**/*.gemspec' do
    gem 'rubocop-config-timedia', require: false
  end
end
