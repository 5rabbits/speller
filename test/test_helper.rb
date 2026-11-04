# Coverage is opt-in (COVERAGE=1), as in the other Lemontech services. CI turns
# it on and keeps coverage/.resultset.json, the file SonarQube will read.
# SimpleCov must start before the app is required, or speller.rb isn't tracked.
if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    cover 'speller.rb'
  end
end

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'json'
require 'rack/test'
require_relative '../speller'
