# frozen_string_literal: true

module OmniAI
  # A namespace for everything Mistral.
  module Mistral
    # @return [OmniAI::Mistral::Config]
    def self.config
      @config ||= OmniAI.config.mistral
    end

    # @yield [OmniAI::Mistral::Config]
    def self.configure
      yield OmniAI.config.mistral
    end
  end
end
