# frozen_string_literal: true

module OmniAI
  class Chat
    # A stream is used to process a series of chunks of data. It converts the following into a combined payload:
    #
    #   { "id":"...", "choices": [{ "index": 0,"delta": { "role" :"assistant", "content":"" } }] }
    #   { "id":"...", "choices": [{ "index": 0,"delta": { "content" :"A" } }] }
    #   { "id":"...", "choices": [{ "index": 0,"delta": { "content" :"B" } }] }
    #   ...
    #
    # Every
    class Stream
      # @param logger [OmniAI::Client]
      # @param chunks [Enumerable<String>]
      # @param context [Context, nil]
      def initialize(chunks:, logger: nil, context: nil)
        @chunks = chunks
        @logger = logger
        @context = context
      end

      # @yield [payload]
      # @yieldparam payload [OmniAI::Chat::Payload]
      #
      # @return [OmniAI::Chat::Payload]
      def stream!(&block)
        OmniAI::Chat::Payload.new.tap do |payload|
          @chunks.map do |chunk|
            parser.feed(chunk) do |type, data, id|
              result = process!(type, data, id, &block)
              payload.merge!(result) if result.is_a?(OmniAI::Chat::Payload)
            end
          end
        end
      end

    protected

      # @param type [String]
      # @param data [String]
      # @param id [String]
      def log(type, data, id)
        arguments = [
          ("type=#{type.inspect}" if type),
          ("data=#{data.inspect}" if data),
          ("id=#{id.inspect}" if id),
        ].compact

        @logger&.debug("Stream#process! #{arguments.join(' ')}")
      end

      # @param type [String]
      # @param data [String]
      # @param id [String]
      #
      # @return [OmniAI::Chat::Payload, nil]
      def process!(type, data, id, &block)
        log(type, data, id)

        return if data.eql?("[DONE]")

        payload = Payload.deserialize(JSON.parse(data), context: @context)
        block&.call(payload)
        payload
      end

      # @return [EventStreamParser::Parser]
      def parser
        @parser ||= EventStreamParser::Parser.new
      end
    end
  end
end
