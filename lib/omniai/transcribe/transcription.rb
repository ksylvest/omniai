# frozen_string_literal: true

module OmniAI
  class Transcribe
    # A transcription returned by the API.
    class Transcription
      attr_accessor :data, :format

      # @param data [Hash]
      def initialize(data:, format:)
        @data = data
        @format = format
      end

      # @return [String]
      def text
        @data['text']
      end

      # @return [String]
      def inspect
        "#<#{self.class} text=#{text.inspect} format=#{format.inspect}>"
      end
    end
  end
end
