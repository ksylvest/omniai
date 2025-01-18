# frozen_string_literal: true

require "logger"
require "simplecov"
require "webmock/rspec"

SimpleCov.start do
  enable_coverage :branch
end

require "omniai"

Dir["#{__dir__}/support/**/*.rb"].each { |file| require file }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
