# frozen_string_literal: true

module OmniAI
  module Anthropic
    # Configuration for Anthropic.
    class Config
      DEFAULT_HOST = "https://api.anthropic.com"
      DEFAULT_VERSION = "2023-06-01"

      # @!attribute [rw] api_key
      #   @return [String, nil]
      attr_accessor :api_key

      # @!attribute [rw] host
      #   @return [String, nil]
      attr_accessor :host

      # @!attribute [rw] version
      #   @return [String, nil] passed as `anthropic-version` if specified
      attr_accessor :version

      # @!attribute [rw] beta
      #   @return [String, nil] passed as `anthropic-beta` if specified
      attr_accessor :beta

      def initialize
        @api_key = ENV.fetch("ANTHROPIC_API_KEY", nil)
        @version = ENV.fetch("ANTHROPIC_VERSION", DEFAULT_VERSION)
        @host = ENV.fetch("ANTHROPIC_HOST", DEFAULT_HOST)
        @beta = ENV.fetch("ANTHROPIC_BETA", nil)
      end
    end
  end
end
