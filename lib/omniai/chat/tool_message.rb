# frozen_string_literal: true

module OmniAI
  class Chat
    # A specific message that contains the result of a tool call.
    class ToolMessage
      # @return [String]
      attr_accessor :content

      # @return [ToolCall]
      attr_accessor :tool_call

      # @param content [String]
      # @param tool_call [ToolCall]
      def initialize(content:, tool_call:)
        @content = content
        @tool_call = tool_call
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} content=#{content.inspect} tool_call=#{tool_call.inspect}>"
      end

      # Usage:
      #
      #   ToolCall.deserialize({ 'role' => 'tool', content: '{ 'temperature': 0 }' }) # => #<ToolCall ...>
      #
      # @param data [Hash]
      # @param context [Context] optional
      #
      # @return [ToolMessage]
      def self.deserialize(data, context: nil)
        deserialize = context&.deserializers&.[](:tool_message)
        return deserialize.call(data, context:) if deserialize

        content = JSON.parse(data['content'])
        tool_call = ToolCall.deserialize(data['tool_call'], context:) if data['tool_call']

        new(content:, tool_call:)
      end

      # Usage:
      #
      #   message.serialize # => { role: :user, content: 'Hello!' }
      #   message.serialize # => { role: :user, content: [{ type: 'text', text: 'Hello!' }] }
      #
      # @param context [Context] optional
      #
      # @return [Hash]
      def serialize(context: nil)
        serializer = context&.serializers&.[](:tool_message)
        return serializer.call(self, context:) if serializer

        { role: 'tool', content: JSON.generate(@content), tool_call_id: @tool_call&.id }
      end
    end
  end
end
