# frozen_string_literal: true

module OmniAI
  class Chat
    # An `OmniAI::Chat::Delta` is used to assist with streaming. It represents a chunk of a conversation that is yielded
    # back to the caller.
    class Delta
      # @!attribute [rw] text
      #
      attr_accessor :text

      # @param text [String]
      def initialize(text:)
        @text = text
      end

      # @return [Boolean]
      def text?
        !text.empty?
      end
    end
  end
end
