# frozen_string_literal: true

module OmniAI
  class Chat
    # The result of a tool call.
    class ToolCallResult
      # @return [Object]
      attr_accessor :content

      # @return [ToolCall]
      attr_accessor :tool_call_id

      # @param content [Object]
      # @param tool_call_id [String]
      def initialize(content:, tool_call_id:)
        @content = content
        @tool_call_id = tool_call_id
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} content=#{content.inspect} tool_call_id=#{tool_call_id.inspect}>"
      end

      # @param context [Context] optional
      # @return [Hash]
      def serialize(context: nil)
        serializer = context&.serializer(:tool_call_result)
        return serializer.call(self, context:) if serializer

        content = JSON.generate(@content)
        tool_call_id = @tool_call_id

        { content:, tool_call_id: }
      end

      # @param data [Hash]
      # @param context [Context] optional
      # @return [ToolCallResult]
      def self.deserialize(data, context: nil)
        deserialize = context&.deserializer(:tool_call_result)
        return deserialize.call(data, context:) if deserialize

        content = JSON.parse(data["content"])
        tool_call_id = data["tool_call_id"]

        new(content:, tool_call_id:)
      end
    end
  end
end
