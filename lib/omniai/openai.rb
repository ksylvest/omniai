# frozen_string_literal: true

module OmniAI
  # A namespace for everything OpenAI.
  module OpenAI
    # @return [OmniAI::OpenAI::Config]
    def self.config
      @config ||= Config.new
    end

    # @yield [OmniAI::OpenAI::Config]
    def self.configure
      yield config
    end
  end
end
