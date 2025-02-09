# frozen_string_literal: true

module OmniAI
  class Transcribe
    # A transcription returned by the API.
    class Transcription
      # @!attribute [rw] text
      #   @return [String]
      attr_accessor :text

      # @!attribute [rw] model
      #   @return [String]
      attr_accessor :model

      # @!attribute [rw] format
      #   @return [String]
      attr_accessor :format

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
