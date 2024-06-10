# frozen_string_literal: true

module OmniAI
  # An abstract class that provides an interface for chatting for various vendors (e.g. OpenAI::ChatGPT).
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
    def initialize(client:)
      @client = client
    end

    # @raise [OmniAI::Error]
    # @param messages [String]
    # @param model [String]
    # @param format [Symbol] either :text or :json
    # @param temperature [Float]
    # @return [OmniAI::Chat::Completion] an instance of OmniAI::Chat::Completion
    def completion(messages, model:, temperature: 0.0, format: :text)
      raise NotImplementedError, "#{self.class.name}#completion undefined"
    end
  end
end
