# frozen_string_literal: true

module OmniAI
  class Chat
    # A set of tool calls to be executed.
    class ToolCallBatch
      attr_accessor :entries

      # @return [Array<ToolCall>]
      def initialize(entries)
        @entries = entries
      end
    end
  end
end
