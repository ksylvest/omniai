# frozen_string_literal: true

module OmniAI
  # A namespace for everything Anthropic.
  module Anthropic
    # @return [OmniAI::Anthropic::Config]
    def self.config
      @config ||= Config.new
    end

    # @yield [OmniAI::Anthropic::Config]
    def self.configure
      yield config
    end
  end
end
