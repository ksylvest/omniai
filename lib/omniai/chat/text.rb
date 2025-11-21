# frozen_string_literal: true

module OmniAI
  class Chat
    # Just some text.
    class Text < Content
      # @return [String]
      attr_accessor :text

      # @param text [text]
      def initialize(text = nil)
        super()
        @text = text
      end

      # @return [String]
      def inspect
        "#<#{self.class} text=#{@text.inspect}>"
      end

      # @return [String]
      def summarize
        @text
      end

      # @param context [Context] optional
      # @param data [Hash] required
      def self.deserialize(data, context: nil)
        deserialize = context&.deserializer(:text)
        return deserialize.call(data, context:) if deserialize

        new(data["text"])
      end

      # @param context [Context] optional
      # @param direction [String] optional - either "input" or "output"
      #
      # @return [Hash]
      def serialize(context: nil, direction: nil)
        serializer = context&.serializer(:text)
        return serializer.call(self, context:, direction:) if serializer

        { type: "text", text: @text }
      end
    end
  end
end
