# frozen_string_literal: true

module OmniAI
  module Anthropic
    class Chat
      # Overrides content serialize / deserialize.
      module ContentSerializer
        # @param data [Hash]
        # @param context [Context]
        # @return [OmniAI::Chat::Text, OmniAI::Chat::ToolCall]
        def self.deserialize(data, context:)
          case data["type"]
          when "text" then OmniAI::Chat::Text.deserialize(data, context:)
          when "tool_use" then OmniAI::Chat::ToolCall.deserialize(data, context:)
          end
        end
      end
    end
  end
end
