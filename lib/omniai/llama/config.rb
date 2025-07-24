# frozen_string_literal: true

module OmniAI
  module Llama
    # Configuration for Llama.
    class Config < OmniAI::Config
      DEFAULT_HOST = "https://api.llama.com"

      # @param api_key [String, nil] optional - defaults to `ENV['LLAMA_API_KEY']`
      # @param host [String, nil] optional - defaults to ENV['LLAMA_HOST'] w/ fallback to `DEFAULT_HOST`
      # @param logger [Logger, nil] optional
      # @param timeout [Integer, Hash, nil] optional
      def initialize(
        api_key: ENV.fetch("LLAMA_API_KEY", nil),
        host: ENV.fetch("LLAMA_HOST", DEFAULT_HOST),
        logger: nil,
        timeout: nil
      )
        super
      end
    end
  end
end
