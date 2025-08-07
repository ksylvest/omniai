# frozen_string_literal: true

module OmniAI
  class Chat
    # An error raised for tool-call issues.
    class ToolCallError < Error
      # @param tool_call [OmniAI::Chat::ToolCall]
      # @param message [String]
      def initialize(tool_call:, message:)
        super(message)
        @tool_call = tool_call
      end
    end
  end
end
