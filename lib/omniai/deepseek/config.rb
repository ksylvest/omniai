# frozen_string_literal: true

module OmniAI
  module DeepSeek
    # Configuration for DeepSeek.
    class Config
      DEFAULT_HOST = "https://api.deepseek.com"

      # @!attribute [rw] api_key
      #   @return [String]
      attr_accessor :api_key

      # @!attribute [rw] host
      #   @return [String]
      attr_accessor :host

      def initialize
        @api_key = ENV.fetch("DEEPSEEK_API_KEY", nil)
        @host = ENV.fetch("DEEPSEEK_HOST", DEFAULT_HOST)
      end
    end
  end
end
