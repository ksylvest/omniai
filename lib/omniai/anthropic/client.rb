# frozen_string_literal: true

module OmniAI
  module Anthropic
    # An Anthropic client implementation. Usage:
    #
    # w/ `api_key``:
    #   client = OmniAI::Anthropic::Client.new(api_key: '...')
    #
    # w/ ENV['ANTHROPIC_API_KEY']:
    #
    #   ENV['ANTHROPIC_API_KEY'] = '...'
    #   client = OmniAI::Anthropic::Client.new
    #
    # w/ config:
    #
    #   OmniAI::Anthropic.configure do |config|
    #     config.api_key = '...'
    #   end
    #
    #   client = OmniAI::Anthropic::Client.new
    class Client < OmniAI::Client
      VERSION = "v1"

      # @param api_key [String] optional - defaults to `OmniAI::Anthropic.config.api_key`
      # @param host [String] optional - defaults to `OmniAI::Anthropic.config.host`
      # @param version [String] optional - defaults to `OmniAI::Anthropic.config.version`
      # @param beta [String] optional - defaults to `OmniAI::Anthropic.config.beta`
      # @param logger [Logger] optional - defaults to `OmniAI::Anthropic.config.logger`
      # @param timeout [Integer] optional - defaults to `OmniAI::Anthropic.config.timeout`
      def initialize(
        api_key: OmniAI::Anthropic.config.api_key,
        host: OmniAI::Anthropic.config.host,
        version: OmniAI::Anthropic.config.version,
        beta: OmniAI::Anthropic.config.beta,
        logger: OmniAI::Anthropic.config.logger,
        timeout: OmniAI::Anthropic.config.timeout
      )
        raise(ArgumentError, %(ENV['ANTHROPIC_API_KEY'] must be defined or `api_key` must be passed)) if api_key.nil?

        super(api_key:, host:, logger:, timeout:)

        @host = host
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
