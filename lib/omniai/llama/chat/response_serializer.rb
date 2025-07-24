# frozen_string_literal: true

module OmniAI
  module Llama
    class Chat
      # Overrides response serialize / deserialize for the following payload:
      #
      #   {
      #     completion_message: {
      #       content: {
      #         type: "text",
      #         text: "Hello!",
      #       },
      #       role: "assistant",
      #       stop_reason: "stop",
      #       tool_calls: [],
      #     },
      #     metrics: [
      #       {
      #         metric: "num_completion_tokens",
      #         value: 2,
      #         unit: "tokens",
      #       },
      #       {
      #         metric: "num_prompt_tokens",
      #         value: 3,
      #         unit: "tokens",
      #       },
      #       {
      #         metric: "num_total_tokens",
      #         value: 4,
      #         unit: "tokens",
      #       },
      #     ],
      #   }
      module ResponseSerializer
        # @param data [Hash]
        # @param context [OmniAI::Context]
        #
        # @return [OmniAI::Chat::Response]
        def self.deserialize(data, context:)
          usage = OmniAI::Chat::Usage.deserialize(data["metrics"], context:) if data["metrics"]
          choice = OmniAI::Chat::Choice.deserialize(data["completion_message"], context:)

          OmniAI::Chat::Response.new(data:, choices: [choice], usage:)
        end
      end
    end
  end
end
