# frozen_string_literal: true

module OmniAI
  # An abstract class that must be subclassed (e.g. OmniAI::OpenAI::Client).
  #
  # Usage:
  #
  #   class OmniAI::OpenAI::Client < OmniAI::Client
  #     def initialize(api_key: ENV.fetch('OPENAI_API_KEY'))
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
    def initialize(api_key:)
      @api_key = api_key
    end

    # @return [HTTP::Client]
    def connection
      HTTP.auth("Bearer #{api_key}")
    end

    # @return [OmniAI::Chat] an instance of OmniAI::Chat
    def chat
      raise NotImplementedError, "#{self.class.name}#chat undefined"
    end
  end
end
