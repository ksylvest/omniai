# frozen_string_literal: true

module OmniAI
  class Chat
    # A processor for streaming back events in chunks.
    class Stream
      LINE_REGEX = /data:\s*(?<data>.*)\n\n/

      def initialize
        @buffer = String.new
      end

      # @yield [data] a parsed hash
      # @param [String] chunk
      def process!(chunk)
        @buffer << chunk

        while (line = @buffer.slice!(LINE_REGEX))
          match = LINE_REGEX.match(line)
          data = match[:data]
          break if data.eql?('[DONE]')

          yield JSON.parse(data)
        end
      end
    end
  end
end
