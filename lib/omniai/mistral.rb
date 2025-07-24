# frozen_string_literal: true

module OmniAI
  # A namespace for everything Mistral.
  module Mistral
    # @return [OmniAI::Mistral::Config]
    def self.config
      @config ||= Config.new
    end

    # @yield [OmniAI::Mistral::Config]
    def self.configure
      yield config
    end
  end
end
