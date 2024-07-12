# frozen_string_literal: true

module OmniAI
  class Chat
    # Either a delta or message.
    class Part
      # @return [Hash]
      attr_accessor :data

      # @param data [Hash]
      def initialize(data:)
        @data = data
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} role=#{role.inspect} content=#{content.inspect}>"
      end

      # @return [String]
      def role
        @data['role'] || Role::USER
      end

      # @return [String, nil]
      def content
        @data['content']
      end

      # @return [Array<OmniAI::Chat::ToolCall>]
      def tool_call_list
        @tool_call_list ||=
          @data['tool_calls'] ? @data['tool_calls'].map { |tool_call_data| ToolCall.new(data: tool_call_data) } : []
      end
    end
  end
end
