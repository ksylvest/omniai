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
      def initialize(
        host: OmniAI.config.deepseek.host,
        api_key: OmniAI.config.deepseek.api_key,
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
