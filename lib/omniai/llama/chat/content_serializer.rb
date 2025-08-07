# frozen_string_literal: true

module OmniAI
  module Llama
    class Chat
      # Overrides content serialize / deserialize.
      module ContentSerializer
        # @param data [Hash]
        # @param context [Context]
        # @return [OmniAI::Chat::Text, OmniAI::Chat::ToolCall]
        def self.deserialize(data, context:)
          if data["tool_call"]
            OmniAI::Chat::ToolCall.deserialize(data, context:)
          else
            data["text"]
          end
        end
      end
    end
  end
end
