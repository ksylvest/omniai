# frozen_string_literal: true

module OmniAI
  class Chat
    # An error raised when a tool-call is missing.
    class ToolCallMissingError < ToolCallError
      def initialize(tool_call:)
        super(tool_call:, message: "missing tool for tool_call=#{tool_call.inspect}")
      end
    end
  end
end
