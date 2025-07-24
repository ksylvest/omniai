# frozen_string_literal: true

module OmniAI
  module Anthropic
    class Chat
      # Overrides tool-call serialize / deserialize.
      module ToolCallSerializer
        # @param tool_call [OmniAI::Chat::ToolCall]
        # @param context [OmniAI::Context]
        # @return [Hash]
        def self.serialize(tool_call, context:)
          function = tool_call.function.serialize(context:)
          {
            id: tool_call.id,
            type: "tool_use",
          }.merge(function)
        end

        # @param data [Hash]
        # @param context [OmniAI::Context]
        # @return [OmniAI::Chat::ToolCall]
        def self.deserialize(data, context:)
          function = OmniAI::Chat::Function.deserialize(data, context:)
          OmniAI::Chat::ToolCall.new(id: data["id"], function:)
        end
      end
    end
  end
end
