# frozen_string_literal: true

module OmniAI
  module Llama
    class Chat
      # Overrides choice serialize / deserialize for the following payload:
      #
      #   {
      #     content: {
      #       type: "text",
      #       text: "Hello!",
      #     },
      #     role: "assistant",
      #     stop_reason: "stop",
      #     tool_calls: [],
      #   }
      module ChoiceSerializer
        # @param data [Hash]
        # @param context [OmniAI::Context]
        #
        # @return [OmniAI::Chat::Response]
        def self.deserialize(data, context:)
          message = OmniAI::Chat::Message.deserialize(data, context:)
          OmniAI::Chat::Choice.new(message:)
        end
      end
    end
  end
end
