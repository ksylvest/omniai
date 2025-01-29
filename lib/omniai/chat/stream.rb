# frozen_string_literal: true

module OmniAI
  class Chat
    # Used when streaming to process chunks of data.
    class Stream
      # @param logger [OmniAI::Client]
      # @param body [HTTP::Response::Body]
      # @param context [Context, nil]
      def initialize(body:, logger: nil, context: nil)
        @body = body
        @logger = logger
        @context = context
      end

      # @yield [payload]
      # @yieldparam payload [OmniAI::Chat::Payload]
      def stream!(&block)
        @body.each do |chunk|
          parser.feed(chunk) do |type, data, id|
            process!(type, data, id, &block)
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
      # @yield [payload]
      # @yieldparam payload [OmniAI::Chat::Payload]
      def process!(type, data, id, &block)
        log(type, data, id)

        return if data.eql?("[DONE]")

        block.call(Payload.deserialize(JSON.parse(data), context: @context))
      end

      # @return [EventStreamParser::Parser]
      def parser
        @parser ||= EventStreamParser::Parser.new
      end
    end
  end
end
