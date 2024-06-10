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
      # @param messages [String] required
      # @param model [String] required
      # @param temperature [Float, nil] optional
      # @param stream [Proc, nil] optional
      # @param format [Symbol, nil] optional - :text or :json
      def initialize(client:, messages:, model:, temperature: nil, stream: nil, format: nil)
        @client = client
        @messages = messages
        @model = model
        @temperature = temperature
        @stream = stream
        @format = format
      end

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
        if @stream
          stream!(response:)
        else
          OmniAI::OpenAI::Chat::Completion.new(data: response.parse)
        end
      end

      # @param response [HTTP::Response]
      # @return [OmniAI::Chat::Chunk]
      def stream!(response:)
        parser = EventStreamParser::Parser.new

        response.body.each do |chunk|
          parser.feed(chunk) do |_, data|
            break if data.eql?('[DONE]')

            chunk = OmniAI::OpenAI::Chat::Chunk.new(data: data.parse)
            @stream.call(chunk)
          end
        end
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
