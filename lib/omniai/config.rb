# frozen_string_literal: true

module OmniAI
  # A configuration for each agent w/ `api_key` / `host` / `logger`.
  #
  # Usage:
  #
  #   OmniAI::OpenAI.config do |config|
  #     config.logger = Logger.new(STDOUT)
  #     config.timeout = 15
  #   end
  class Config
    # @!attribute [rw] logger
    #   @return [Logger, nil]
    attr_accessor :logger

    # @!attribute [rw] timeout
    #   @return [Integer, Hash{Symbol => Integer}, nil]
    #   @option timeout [Integer] :read
    #   @option timeout [Integer] :write
    #   @option timeout [Integer] :connect
    attr_accessor :timeout

    # @param logger [Logger] optional
    # @param timeout [Integer] optional
    def initialize(logger: nil, timeout: nil)
      @logger = logger
      @timeout = timeout
    end

    # @return [String]
    def inspect
      masked_api_key = "#{api_key[..2]}***" if api_key
      "#<#{self.class.name} api_key=#{masked_api_key.inspect} host=#{host.inspect}>"
    end

    # @return [OmniAI::Anthropic::Config]
    def anthropic
      @anthropic ||= OmniAI::Anthropic::Config.new
    end

    # @return [OmniAI::DeepSeek::Config]
    def deepseek
      @deepseek ||= OmniAI::DeepSeek::Config.new
    end

    # @return [OmniAI::Llama::Config]
    def llama
      @llama ||= OmniAI::Llama::Config.new
    end

    # @return [OmniAI::Google::Config]
    def google
      @google ||= OmniAI::Google::Config.new
    end

    # @return [OmniAI::Mistral::Config]
    def mistral
      @mistral ||= OmniAI::Mistral::Config.new
    end

    # @return [OmniAI::OpenAI::Config]
    def openai
      @openai ||= OmniAI::OpenAI::Config.new
    end
  end
end
