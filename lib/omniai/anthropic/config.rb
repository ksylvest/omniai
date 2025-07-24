# frozen_string_literal: true

module OmniAI
  module Anthropic
    # Configuration for Anthropic.
    class Config < OmniAI::Config
      DEFAULT_HOST = "https://api.anthropic.com"
      DEFAULT_VERSION = "2023-06-01"

      # @!attribute [rw] version
      #   @return [String, nil] passed as `anthropic-version` if specified
      attr_accessor :version

      # @!attribute [rw] beta
      #   @return [String, nil] passed as `anthropic-beta` if specified
      attr_accessor :beta

      # @param api_key [String, nil] optional - defaults to `ENV['ANTHROPIC_API_KEY']`
      # @param host [String, nil] optional - defaults to `ENV['ANTHROPIC_HOST'] w/ fallback to `DEFAULT_HOST`
      # @param version [String, nil] optional - defaults to `ENV['ANTHROPIC_VERSION'] w/ fallback to `DEFAULT_VERSION`
      # @param beta [String, nil] optional - defaults to `ENV['ANTHROPIC_BETA']`
      # @param logger [Logger, nil] optional - defaults to
      # @param timeout [Integer, Hash, nil] optional
      def initialize(
        api_key: ENV.fetch("ANTHROPIC_API_KEY", nil),
        host: ENV.fetch("ANTHROPIC_HOST", DEFAULT_HOST),
        version: ENV.fetch("ANTHROPIC_VERSION", DEFAULT_VERSION),
        beta: ENV.fetch("ANTHROPIC_BETA", nil),
        logger: nil,
        timeout: nil
      )
        super(api_key:, host:, logger:, timeout:)
        @version = version
        @beta = beta
        @chat_options[:max_tokens] = 4096
      end
    end
  end
end
