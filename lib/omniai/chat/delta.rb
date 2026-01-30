# frozen_string_literal: true

module OmniAI
  class Chat
    # An `OmniAI::Chat::Delta` is used to assist with streaming. It represents a chunk of a conversation that is yielded
    # back to the caller.
    class Delta
      # @!attribute [rw] text
      #   @return [String, nil]
      attr_accessor :text

      # @!attribute [rw] thinking
      #   @return [String, nil]
      attr_accessor :thinking

      # @param text [String, nil]
      # @param thinking [String, nil]
      def initialize(text: nil, thinking: nil)
        @text = text
        @thinking = thinking
      end

      # @return [Boolean]
      def text?
        !@text.nil? && !@text.empty?
      end

      # @return [Boolean]
      def thinking?
        !@thinking.nil? && !@thinking.empty?
      end
    end
  end
end
