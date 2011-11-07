require 'simplecov'
SimpleCov.start

require 'sinatra/named_routes'
require 'sinatra/contrib'

RSpec.configure do |config|
  config.expect_with :rspec, :stdlib
  config.include Sinatra::TestHelpers
end