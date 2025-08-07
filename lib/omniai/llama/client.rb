# frozen_string_literal: true

module OmniAI
  module Llama
    # A Llama client implementation. Usage:
    #
    # w/ `api_key``:
    #   client = OmniAI::Llama::Client.new(api_key: '...')
    #
    # w/ ENV['LLAMA_API_KEY']:
    #
    #   ENV['LLAMA_API_KEY'] = '...'
    #   client = OmniAI::Llama::Client.new
    #
    # w/ config:
    #
    #   OmniAI::Llama.configure do |config|
    #     config.api_key = '...'
    #   end
    #
    #   client = OmniAI::Llama::Client.new
    class Client < OmniAI::Client
      VERSION = "v1"

      # @param host [String] optional (default: OmniAI.config.llama.host)
      # @param api_key [String] optional (default: OmniAI.config.llama.api_key)
      # @param logger [Logger] optional (default: OmniAI.config.logger)
      # @param timeout [Integer] optional (default: OmniAI.config.timeout)
      # @param config [OmniAI::Config] optional (default: OmniAI.config
      def initialize(
        api_key: OmniAI.config.llama.api_key,
        host: OmniAI.config.llama.host,
        logger: OmniAI.config.logger,
        timeout: OmniAI.config.timeout
      )
        super(host:, logger:, timeout:)
        @api_key = api_key
      end

      # @return [HTTP::Client]
      def connection
        @connection ||= super.auth("Bearer #{@api_key}")
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
