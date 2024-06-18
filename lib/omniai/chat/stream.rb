# frozen_string_literal: true

module OmniAI
  class Chat
    # A stream given when streaming.
    class Stream
      # @param response [HTTP::Response]
      def initialize(response:)
        @response = response
        @parser = EventStreamParser::Parser.new
      end

      # @yield [OmniAI::Chat::Chunk]
      def stream!
        @response.body.each do |chunk|
          @parser.feed(chunk) do |_, data|
            next if data.eql?('[DONE]')

            yield(Chunk.new(data: JSON.parse(data)))
          end
        end
      end
    end
  end
end
