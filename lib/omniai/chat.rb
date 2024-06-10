# frozen_string_literal: true

module OmniAI
  # An abstract class that provides an interface for chatting for various vendors (e.g. OpenAI’s ChatGPT).
  #
  # Usage:
  #
  #   class OmniAI::OpenAI::Chat < OmniAI::Chat
  #     def completion(messages, model:, temperature: 0.0, format: :text)
  #       # TODO: implement
  #     end
  #   end
  #
  # Once defined, it can be used to interface with the vendor's chat API as follows:
  #
  #   client.chat.completion("...", model: "...", temperature: 0.0, format: :text)
  #
  # @param client [OmniAI::Client] the client
  class Chat
    module Role
      ASSISTANT = 'assistant'
      USER = 'user'
      SYSTEM = 'system'
    end

    def initialize(client:)
      @client = client
    end

    # @raise [OmniAI::Error]
    #
    # @param messages [String, Array, Hash, OmnniAI::Chat::Message]
    # @param model [String] optional
    # @param format [Symbol] optional :text or :json
    # @param temperature [Float, nil] optional
    # @param stream [Proc, nil] optional
    #
    # @return [OmniAI::Chat::Request]
    def completion(messages, model:, temperature: nil, format: nil, stream: nil)
      raise NotImplementedError, "#{self.class.name}#completion undefined"
    end
  end
end
