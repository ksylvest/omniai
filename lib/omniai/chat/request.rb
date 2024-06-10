# frozen_string_literal: true

module OmniAI
  class Chat
    # An abstract class that provides a consistent interface for processing chat requests.
    #
    # Usage:
    #
    #    class OmniAI::OpenAI::ChatGPT::Request < OmniAI::Chat::Request
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
      # @param format [Symbol, nil] optional - :json
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

      # @return [Hash]
      def payload
        raise NotImplementedError, "#{self.class.name}#payload undefined"
      end

      # @return [String]
      def path
        raise NotImplementedError, "#{self.class.name}#path undefined"
      end

      # @param response [HTTP::Response]
      # @return [OmniAI::Chat::Completion]
      def parse!(response:)
        if @stream
          stream!(response:)
        else
          complete!(response:)
        end
      end

      # @param response [OmniAI::Chat::Completion]
      def complete!(response:)
        Completion.new(data: response.parse)
      end

      # @param response [HTTP::Response]
      # @return [OmniAI::Chat::Stream]
      def stream!(response:)
        raise Error, "#{self.class.name}#stream! unstreamable" unless @stream

        Stream.new(response:).stream! { |chunk| @stream.call(chunk) }
      end

      # @return [Array<Hash>]
      def messages
        arrayify(@messages).map do |content|
          case content
          when String then { role: OmniAI::Chat::Role::USER, content: }
          when Hash then content
          else raise Error, "Unsupported content=#{content.inspect}"
          end
        end
      end

      # @param value [Object, Array<Object>]
      # @return [Array<Object>]
      def arrayify(value)
        value.is_a?(Array) ? value : [value]
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
