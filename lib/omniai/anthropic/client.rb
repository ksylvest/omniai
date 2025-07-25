# frozen_string_literal: true

module OmniAI
  module Anthropic
    # An Anthropic client implementation. Usage:
    #
    #   client = OmniAI::Anthropic::Client.new
    #   client.chat(...)
    class Client < OmniAI::Client
      VERSION = "v1"

      # @param api_key [String] optional (default: OmniAI.config.anthropic.api_key)
      # @param version [String] optional (default: OmniAI.config.anthropic.version)
      # @param beta [Boolean] optional (default: OmniAI.config.anthropic.beta)
      # @param host [String] optional (default: OmniAI.config.anthropic.host)
      # @param timeout [Integer] optional (default: OmniAI.config.timeout)
      # @param logger [Logger] optional (default: OmniAI.config.logger)
      def initialize(
        api_key: OmniAI.config.anthropic.api_key,
        version: OmniAI.config.anthropic.version,
        beta: OmniAI.config.anthropic.beta,
        host: OmniAI.config.anthropic.host,
        timeout: OmniAI.config.timeout,
        logger: OmniAI.config.logger
      )
        super(host:, logger:, timeout:)

        @api_key = api_key
        @version = version
        @beta = beta
      end

      # @return [HTTP::Client]
      def connection
        @connection ||= super.headers({
          "x-api-key": @api_key,
          "anthropic-version": @version,
          "anthropic-beta": @beta,
        }.compact)
      end

      # @raise [OmniAI::Error]
      #
      # @param messages [String] optional
      # @param model [String] optional
      # @param format [Symbol] optional :text or :json
      # @param temperature [Float, nil] optional
      # @param stream [Proc, nil] optional
      # @param tools [Array<OmniAI::Tool>, nil] optional
      #
      # @yield [prompt]
      # @yieldparam prompt [OmniAI::Chat::Prompt]
      #
      # @return [OmniAI::Chat::Completion]
      def chat(messages = nil, model: Chat::DEFAULT_MODEL, temperature: nil, format: nil, stream: nil, tools: nil, &)
        Chat.process!(messages, model:, temperature:, format:, stream:, tools:, client: self, &)
      end
    end
  end
end
