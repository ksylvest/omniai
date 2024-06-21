# frozen_string_literal: true

module OmniAI
  # A configuration for each agent w/ `api_key` / `host` / `logger`. Usage:
  #
  #   OmniAI::OpenAI.config do |config|
  #     config.api_key = '...'
  #     config.host = 'http://localhost:8080'
  #     config.logger = Logger.new(STDOUT)
  #     config.timeout = 15
  #     config.chat_options = { ... }
  #     config.transcribe_options = { ... }
  #     config.speak_options = { ... }
  #   end
  class Config
    # @return [String, nil]
    attr_accessor :api_key

    # @return [String, nil]
    attr_accessor :host

    # @return [Logger, nil]
    attr_accessor :logger

    # @return [Integer, Hash{Symbol => Integer}, nil]
    # @option timeout [Integer] :read
    # @option timeout [Integer] :write
    # @option timeout [Integer] :connect
    attr_accessor :timeout

    # @return [Hash]
    attr_accessor :chat_options

    # @return [Hash]
    attr_accessor :transcribe_options

    # @return [Hash]
    attr_accessor :speak_options

    # @param api_key [String] optional
    # @param host [String] optional
    # @param logger [Logger] optional
    # @param timeout [Integer] optional
    def initialize(api_key: nil, host: nil, logger: nil, timeout: nil)
      @api_key = api_key
      @host = host
      @logger = logger
      @timeout = timeout

      @chat_options = {}
      @transcribe_options = {}
      @speak_options = {}
    end

    # @return [String]
    def inspect
      masked_api_key = "#{api_key[..2]}***" if api_key
      "#<#{self.class.name} api_key=#{masked_api_key.inspect} host=#{host.inspect}>"
    end
  end
end
