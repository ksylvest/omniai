# frozen_string_literal: true

module OmniAI
  class Transcribe
    # A transcription returned by the API.
    class Transcription
      attr_accessor :text, :model, :format

      # @param text [String]
      # @param model [String]
      # @param format [String]
      def initialize(text:, model:, format:)
        @text = text
        @model = model
        @format = format
      end

      # @return [String]
      def inspect
        "#<#{self.class} text=#{text.inspect}>"
      end
    end
  end
end
