ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'json'
require 'rack/test'
require_relative '../speller'
