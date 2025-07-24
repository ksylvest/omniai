# frozen_string_literal: true

module OmniAI
  module DeepSeek
    # An DeepSeek client implementation. Usage:
    #
    # w/ `api_key``:
    #   client = OmniAI::DeepSeek::Client.new(api_key: '...')
    #
    # w/ ENV['DEEPSEEK_API_KEY']:
    #
    #   ENV['DEEPSEEK_API_KEY'] = '...'
    #   client = OmniAI::DeepSeek::Client.new
    #
    # w/ config:
    #
    #   OmniAI::DeepSeek.configure do |config|
    #     config.api_key = '...'
    #   end
    #
    #   client = OmniAI::DeepSeek::Client.new
    class Client < OmniAI::Client
      # @param api_key [String, nil] optional - defaults to `OmniAI::DeepSeek.config.api_key`
      # @param host [String] optional - defaults to `OmniAI::DeepSeek.config.host`
      # @param logger [Logger, nil] optional - defaults to `OmniAI::DeepSeek.config.logger`
      # @param timeout [Integer, nil] optional - defaults to `OmniAI::DeepSeek.config.timeout`
      def initialize(
        api_key: OmniAI::DeepSeek.config.api_key,
        host: OmniAI::DeepSeek.config.host,
        logger: OmniAI::DeepSeek.config.logger,
        timeout: OmniAI::DeepSeek.config.timeout
      )
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
