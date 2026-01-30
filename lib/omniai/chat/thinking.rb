# frozen_string_literal: true

module OmniAI
  class Chat
    # Represents thinking/reasoning content from a model.
    class Thinking < Content
      # @return [String]
      attr_accessor :thinking

      # @return [Hash] Provider-specific metadata (e.g., Anthropic's signature)
      attr_accessor :metadata

      # @param thinking [String]
      # @param metadata [Hash] Provider-specific data for round-tripping
      def initialize(thinking = nil, metadata: {})
        super()
        @thinking = thinking
        @metadata = metadata || {}
      end

      # @return [String]
      def inspect
        "#<#{self.class} thinking=#{@thinking.inspect}>"
      end

      # @return [String]
      def summarize
        @thinking
      end

      # @param data [Hash] required
      # @param context [Context] optional
      def self.deserialize(data, context: nil)
        deserialize = context&.deserializer(:thinking)
        return deserialize.call(data, context:) if deserialize

        new(data["thinking"])
      end

      # @param context [Context] optional
      # @param direction [String] optional - either "input" or "output"
      #
      # @return [Hash]
      def serialize(context: nil, direction: nil) # rubocop:disable Lint/UnusedMethodArgument
        serializer = context&.serializer(:thinking)
        return serializer.call(self, context:) if serializer

        { type: "thinking", thinking: @thinking }
      end
    end
  end
end
