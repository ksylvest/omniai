# frozen_string_literal: true

module OmniAI
  class Chat
    # The result of a tool call.
    class ToolCallResult
      # @!attribute [rw] content
      #   @return [Object]
      attr_accessor :content

      # @!attribute [rw] tool_call_id
      #   @return [ToolCall]
      attr_accessor :tool_call_id

      # @!attribute [r] options
      #   @return [Hash] provider-specific options
      attr_reader :options

      # @param content [Object] e.g. a string, hash, array, boolean, numeric, etc.
      # @param tool_call_id [String]
      # @param options [Hash] optional - used for provider-specific options
      def initialize(content:, tool_call_id:, **options)
        @content = content
        @tool_call_id = tool_call_id
        @options = options
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} content=#{content.inspect} tool_call_id=#{tool_call_id.inspect}>"
      end

      # Converts the content of a tool call result to JSON unless the result is a string.
      #
      # @return [String, nil]
      def text
        return content if content.nil? || content.is_a?(String)

        JSON.generate(@content)
      end

      # @param context [Context] optional
      #
      # @return [Hash]
      def serialize(context: nil)
        serializer = context&.serializer(:tool_call_result)
        return serializer.call(self, context:) if serializer

        content = text
        tool_call_id = @tool_call_id

        { content:, tool_call_id: }
      end

      # @param data [Hash]
      # @param context [Context] optional
      #
      # @return [ToolCallResult]
      def self.deserialize(data, context: nil)
        deserialize = context&.deserializer(:tool_call_result)
        return deserialize.call(data, context:) if deserialize

        content = data["content"]
        tool_call_id = data["tool_call_id"]

        new(content:, tool_call_id:)
      end
    end
  end
end
