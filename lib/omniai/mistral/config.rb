# frozen_string_literal: true

module OmniAI
  module Mistral
    # Configuration for Mistral.
    class Config < OmniAI::Config
      DEFAULT_HOST = "https://api.mistral.ai"

      # @param api_key [String, nil] optional - defaults to `ENV['MISTRAL_API_KEY']`
      # @param host [String, nil] optional - defaults to `ENV['MISTRAL_HOST'] w/ fallback to `DEFAULT_HOST`
      # @param logger [Logger, nil] optional - defaults to
      # @param timeout [Integer, Hash, nil] optional
      def initialize(
        api_key: ENV.fetch("MISTRAL_API_KEY", nil),
        host: ENV.fetch("MISTRAL_HOST", DEFAULT_HOST),
        logger: nil,
        timeout: nil
      )
        super
      end
    end
  end
end
