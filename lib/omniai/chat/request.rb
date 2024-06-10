# frozen_string_literal: true

module OmniAI
  class Chat
    # An abstract class that provides a consistent interface for processing chat requests.
    #
    # Usage:
    #
    #    class OmniAI::OpenAI::ChatGPT::Completion < OmniAI::Chat::Completion
    #      module Model
    #        CHAT = "davinci"
    #      end
    #      def completion(messages, model:, temperature: 0.0, format: :text)
    #      end
    #    end
    #
    # Once defined, the subclass can be used to interface with the vendor's chat API as follows:
    #
    #    client.chat.completion(messages, model: "...", temperature: 0.0, format: :text)
    class Request
      # @param client [OmniAI::Client] the client
      # @param messages [String]
      # @param model [String]
      # @param temperature [Float]
      # @param format [Symbol] either :text or :json
      def initialize(client:, messages:, model:, temperature: 0.0, format: :text)
        @client = client
        @messages = messages
        @model = model
        @temperature = temperature
        @format = format
      end

      # @param prompt [String, Message]
      # @param model [String]
      # @param format [Symbol] either :text or :json
      # @param temperature [Float]
      # @return [Hash]
      # @raise [ExecutionError]
      def process!
        response = request!
        raise HTTPError, response unless response.status.ok?

        parse!(response:)
      end

      protected

      # @param response [HTTP::Response]
      # @return [OmniAI::Chat::Completion::Response]
      def parse!(response:)
        raise NotImplementedError, "#{self.class.name}#parse! undefined"
      end

      # @return [Hash]
      def payload
        raise NotImplementedError, "#{self.class.name}#payload undefined"
      end

      # @return [String]
      def path
        raise NotImplementedError, "#{self.class.name}#path undefined"
      end

      # @return [HTTP::Response]
      def request!
        @client
          .connection
          .accept(:json)
          .post(path, json: payload)
      end
    end
  end
end
