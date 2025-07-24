# frozen_string_literal: true

module OmniAI
  module DeepSeek
    # Configuration for DeepSeek.
    class Config < OmniAI::Config
      DEFAULT_HOST = "https://api.deepseek.com"

      # @param api_key [String, nil] optional - defaults to `ENV['DEEPSEEK_API_KEY']`
      # @param host [String, nil] optional - defaults to ENV['DEEPSEEK_HOST'] w/ fallback to `DEFAULT_HOST`
      # @param logger [Logger, nil] optional
      # @param timeout [Integer, Hash, nil] optional
      def initialize(
        api_key: ENV.fetch("DEEPSEEK_API_KEY", nil),
        host: ENV.fetch("DEEPSEEK_HOST", DEFAULT_HOST),
        logger: nil,
        timeout: nil
      )
        super
      end
    end
  end
end
