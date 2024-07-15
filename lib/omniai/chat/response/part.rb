# frozen_string_literal: true

module OmniAI
  class Chat
    module Response
      # Either a delta or message.
      class Part < Resource
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

        # @return [Array<ToolCall>]
        def tool_call_list
          return [] unless @data['tool_calls']

          @tool_call_list ||= @data['tool_calls'].map { |tool_call_data| ToolCall.new(data: tool_call_data) }
        end

        # @param index [Integer]
        # @return [ToolCall, nil]
        def tool_call(index: 0)
          tool_call_list[index]
        end
      end
    end
  end
end
