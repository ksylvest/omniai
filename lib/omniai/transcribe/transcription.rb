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

      # @!attribute [rw] duration
      #   @return [Float, nil]
      attr_accessor :duration

      # @!attribute [rw] segments
      #   @return [Array<Hash>, nil]
      attr_accessor :segments

      # @!attribute [rw] language
      #   @return [String, nil]
      attr_accessor :language

      # @param data [Hash, String]
      # @param model [String]
      # @param format [String]
      #
      # @return [OmniAI::Transcribe::Transcription]
      def self.parse(data:, model:, format:)
        data = { "text" => data } if data.is_a?(String)

        text = data["text"]
        duration = data["duration"]
        segments = data["segments"]
        language = data["language"]

        new(text:, model:, format:, duration:, segments:, language:)
      end

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
        attrs = [
          ("text=#{@text.inspect}" if @text),
          ("model=#{@model.inspect}" if @model),
          ("format=#{@format.inspect}" if @format),
          ("duration=#{@duration.inspect}" if @duration),
        ].compact.join(" ")

        "#<#{self.class} #{attrs}>"
      end
    end
  end
end
