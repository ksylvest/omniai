# frozen_string_literal: true

module OmniAI
  class Chat
    # A specific message that contains the result of a tool call.
    class ToolCallMessage < Message
      # @return [String]
      attr_accessor :tool_call_id

      # @param content [String]
      # @param tool_call_id [String]
      def initialize(content:, tool_call_id:, role: OmniAI::Chat::Role::TOOL)
        super(content:, role:)
        @tool_call_id = tool_call_id
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} content=#{content.inspect} tool_call_id=#{tool_call_id.inspect}>"
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
        deserialize = context&.deserializer(:tool_call_message)
        return deserialize.call(data, context:) if deserialize

        role = data["role"]
        content = JSON.parse(data["content"])
        tool_call_id = data["tool_call_id"]

        new(role:, content:, tool_call_id:)
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
        serializer = context&.serializer(:tool_call_message)
        return serializer.call(self, context:) if serializer

        role = @role
        content = JSON.generate(@content)
        tool_call_id = @tool_call_id

        { role:, content:, tool_call_id: }
      end
    end
  end
end
