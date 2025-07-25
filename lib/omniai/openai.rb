# frozen_string_literal: true

module OmniAI
  # A namespace for everything OpenAI.
  module OpenAI
    # @return [OmniAI::OpenAI::Config]
    def self.config
      @config ||= OmniAI.config.openai
    end

    # @yield [OmniAI::OpenAI::Config]
    def self.configure
      yield OmniAI.config.openai
    end
  end
end
