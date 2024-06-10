# frozen_string_literal: true

module OmniAI
  # An abstract class that must be subclassed (e.g. OmniAI::OpenAI::Client).
  #
  # Usage:
  #
  #   class OmniAI::OpenAI::Client < OmniAI::Client
  #     def initialize(api_key: ENV.fetch('OPENAI_API_KEY'), logger: nil)
  #       super
  #     end
  #
  #     @return [OmniAI::OpenAI::Chat]
  #     def chat
  #       # TODO: implement
  #     end
  #   end
  class Client
    class Error < StandardError; end

    attr_accessor :api_key

    # @param api_key [String]
    # @param logger [Logger]
    def initialize(api_key:, logger: nil)
      @api_key = api_key
      @logger = logger
    end

    # @return [String]
    def inspect
      masked_api_key = "#{api_key[..2]}***" if api_key
      "#<#{self.class.name} api_key=#{masked_api_key.inspect}>"
    end

    # @return [HTTP::Client]
    def connection
      raise NotImplementedError, "#{self.class.name}#connection undefined"
    end

    # @return [OmniAI::Chat] an instance of OmniAI::Chat
    def chat
      raise NotImplementedError, "#{self.class.name}#chat undefined"
    end
  end
end
