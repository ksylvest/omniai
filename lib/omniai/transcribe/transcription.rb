# frozen_string_literal: true

module OmniAI
  class Transcribe
    # A transcription returned by the API.
    class Transcription
      # @!attribute [rw] text
      # @return [String]
      attr_accessor :text

      # @!attribute [rw] model
      # @return [String]
      attr_accessor :model

      # @!attribute [rw] format
      # @return [String]
      attr_accessor :format

      # @!attribute [rw] duration
      # @return [Float, nil]
      attr_accessor :duration

      # @!attribute [rw] segments
      # @return [Array, nil]
      attr_accessor :segments

      # @!attribute [rw] language
      # @return [String, nil]
      attr_accessor :language

      # @param text [String]
      # @param model [String]
      # @param format [String]
      # @param duration [Float, nil]
      # @param segments [Array, nil]
      # @param language [String, nil]
      def initialize(text:, model:, format:, duration: nil, segments: nil, language: nil)
        @text = text
        @model = model
        @format = format
        @duration = duration
        @segments = segments
        @language = language
      end

      # @return [String]
      def inspect
        attrs = ["text=#{text.inspect}"]
        attrs << "duration=#{duration}s" if duration
        attrs << "language=#{language}" if language
        attrs << "segments=#{segments.length}" if segments&.any?

        "#<#{self.class} #{attrs.join(' ')}>"
      end
    end
  end
end
