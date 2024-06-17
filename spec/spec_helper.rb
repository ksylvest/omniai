# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  enable_coverage :branch
end

require 'omniai'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
