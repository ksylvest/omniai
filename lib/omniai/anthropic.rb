# frozen_string_literal: true

module OmniAI
  # A namespace for everything Anthropic.
  module Anthropic
    # @return [OmniAI::Anthropic::Config]
    def self.config
      OmniAI.config.anthropic
    end

    # @yield [OmniAI::Anthropic::Config]
    def self.configure
      yield OmniAI.config.anthropic
    end
  end
end
