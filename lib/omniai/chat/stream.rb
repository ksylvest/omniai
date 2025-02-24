# frozen_string_literal: true

module OmniAI
  class Chat
    # Used when streaming to process chunks of data.
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
      # @return [Array<OmniAI::Chat::Payload>]
      def stream!(&block)
        payloads = []
        @chunks.map do |chunk|
          parser.feed(chunk) do |type, data, id|
            payload = process!(type, data, id, &block)
            payloads << payload if payload
          end
        end
        payloads
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
      # @return [OmniAI::Chat::Payload]
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
