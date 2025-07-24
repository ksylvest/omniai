# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Thread
      # An OpenAI text w/ annotations.
      class Text
        # @!attribute [rw] data
        #   @return [Hash, nil]
        attr_accessor :data

        # @param data [Hash]
        # @param client [OmniAI::OpenAI::Client]
        def initialize(data:, client:)
          @data = data
          @client = client
        end

        # @return [String]
        def annotate!
          text = value

          annotations.each do |annotation|
            file = annotation.file!
            text = text.gsub(annotation.text, "[#{file.filename}:#{annotation.range}]")
          end

          text
        end

        # @return [String] e.g. "text"
        def type
          @data["type"]
        end

        # @return [String]
        def value
          @data["value"]
        end

        # @return [Array<OmniAI::OpenAI::Thread::Annotation>]
        def annotations
          @annotations ||= @data["annotations"].map { |data| Annotation.new(data:, client: @client) }
        end
      end
    end
  end
end
