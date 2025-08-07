# frozen_string_literal: true

module OmniAI
  module Mistral
    # An Mistral client implementation. Usage:
    #
    # w/ `api_key``:
    #   client = OmniAI::Mistral::Client.new(api_key: '...')
    #
    # w/ ENV['MISTRAL_API_KEY']:
    #
    #   ENV['MISTRAL_API_KEY'] = '...'
    #   client = OmniAI::Mistral::Client.new
    #
    # w/ config:
    #
    #   OmniAI::Mistral.configure do |config|
    #     config.api_key = '...'
    #   end
    #
    #   client = OmniAI::Mistral::Client.new
    class Client < OmniAI::Client
      VERSION = "v1"

      # @param host [String] optional (default: OmniAI.config.mistral.host)
      # @param api_key [String] optional (default: OmniAI.config.mistral.api_key)
      # @param logger [Logger] optional (default: OmniAI.config.logger)
      # @param timeout [Integer] optional (default: OmniAI.config.timeout)
      # @param config [OmniAI::Config] optional (default: OmniAI.config
      def initialize(
        host: OmniAI.config.mistral.host,
        api_key: OmniAI.config.mistral.api_key,
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
      # @yield [prompt] optional
      # @yieldparam prompt [OmniAI::Chat::Prompt]
      #
      # @return [OmniAI::Chat::Response]
      def chat(messages = nil, model: Chat::DEFAULT_MODEL, temperature: nil, format: nil, stream: nil, tools: nil, &)
        Chat.process!(messages, model:, temperature:, format:, stream:, tools:, client: self, &)
      end

      # @raise [OmniAI::Error]
      #
      # @param input [String, Array<String>, Array<Integer>] required
      # @param model [String] optional
      #
      # @return [OmniAI::Embed::Response]
      def embed(input, model: Embed::DEFAULT_MODEL)
        Embed.process!(input, model:, client: self)
      end

      # @raise [OmniAI::Error]
      #
      # @param document [String] e.g. "https://vancouver.ca/files/cov/other-sectors-tourism.PDF"
      # @param kind [Symbol] optional - `:document` or `:image` - default = `:document``
      # @param model [String] optional - default = "mistral-ocr-latest"
      # @param options [Hash] optional - e.g. `{ image_limit: 4 }`
      #
      # @raise [OmniAI::Error]
      #
      # @return [OmniAI::Mistral::OCR::Response]
      def ocr(document, kind: OCR::DEFAULT_KIND, model: OCR::DEFAULT_MODEL, options: {})
        OCR.process!(document, kind:, model:, options:, client: self)
      end
    end
  end
end
