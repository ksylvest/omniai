# frozen_string_literal: true

module OmniAI
  class Chat
    # Used when streaming to process chunks of data.
    class Stream
      # @param body [HTTP::Response::Body]
      # @param context [Context, nil]
      def initialize(body:, context: nil)
        @body = body
        @context = context
      end

      # @yield [OmniAI::Chat::Chunk]
      def stream!
        @body.each do |chunk|
          parser.feed(chunk) do |_, data|
            next if data.eql?('[DONE]')

            yield(Payload.deserialize(JSON.parse(data), context: @context))
          end
        end
      end

      protected

      # @return [EventStreamParser::Parser]
      def parser
        @parser ||= EventStreamParser::Parser.new
      end
    end
  end
end
