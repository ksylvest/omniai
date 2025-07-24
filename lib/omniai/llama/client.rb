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

      # @param api_key [String, nil] optional - defaults to `OmniAI::Llama.config.api_key`
      # @param host [String] optional - defaults to `OmniAI::Llama.config.host`
      # @param logger [Logger, nil] optional - defaults to `OmniAI::Llama.config.logger`
      # @param timeout [Integer, nil] optional - defaults to `OmniAI::Llama.config.timeout`
      def initialize(
        api_key: OmniAI::Llama.config.api_key,
        host: OmniAI::Llama.config.host,
        logger: OmniAI::Llama.config.logger,
        timeout: OmniAI::Llama.config.timeout
      )
        raise(ArgumentError, %(ENV['LLAMA_API_KEY'] must be defined or `api_key` must be passed)) if api_key.nil?

        super
      end

      # @return [HTTP::Client]
      def connection
        @connection ||= begin
          http = super
          http = http.auth("Bearer #{@api_key}") if @api_key
          http
        end
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
