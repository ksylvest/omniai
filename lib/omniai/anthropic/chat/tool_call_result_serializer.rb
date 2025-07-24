# frozen_string_literal: true

module OmniAI
  module Anthropic
    class Chat
      # Overrides tool-call response serialize / deserialize.
      module ToolCallResultSerializer
        # @param tool_call_result [OmniAI::Chat::ToolCallResult]
        #
        # @return [Hash]
        def self.serialize(tool_call_result, *)
          {
            type: "tool_result",
            tool_use_id: tool_call_result.tool_call_id,
            content: tool_call_result.text,
          }
        end

        # @param data [Hash]
        #
        # @return [OmniAI::Chat::ToolCallResult]
        def self.deserialize(data, *)
          tool_call_id = data["tool_use_id"]
          content = data["content"]

          OmniAI::Chat::ToolCallResult.new(content:, tool_call_id:)
        end
      end
    end
  end
end
