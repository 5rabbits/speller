source 'https://rubygems.org'

ruby file: '.ruby-version'

# Classy web-development dressed in a DSL
gem 'sinatra', '~> 4.2'

# Rack 3 moved the server launcher (rackup, SpellerApp.run!) out of rack
gem 'rackup', '~> 2.3'
gem 'puma', '~> 8.0'

# Load aspell dynamically for spellcheck
gem 'ffi-aspell', '~> 1.1'

group :development do
  # Restarts the server when source files change
  gem 'rerun', '~> 0.14'
  # Language server and debugger for the VS Code Ruby LSP extension (run in the
  # container). Kept here so the image has them and Ruby LSP installs nothing.
  gem 'ruby-lsp', '~> 0.26', require: false
  gem 'debug', '~> 1.11', require: false
end

group :test do
  gem 'minitest', '~> 6.0'
  gem 'rake', '~> 13.4'
  # Drives the Sinatra app in request tests
  gem 'rack-test', '~> 2.3'
  # Coverage report, opt-in with COVERAGE=1 (see test/test_helper.rb)
  gem 'simplecov', '~> 1.3', require: false
end
