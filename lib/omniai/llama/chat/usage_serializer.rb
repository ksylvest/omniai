# frozen_string_literal: true

module OmniAI
  module Llama
    class Chat
      # Overrides response serialize / deserialize for the following payload:
      #
      #   [
      #     {
      #       metric: "num_completion_tokens",
      #       value: 2,
      #       unit: "tokens",
      #     },
      #     {
      #       metric: "num_prompt_tokens",
      #       value: 3,
      #       unit: "tokens",
      #     },
      #     {
      #       metric: "num_total_tokens",
      #       value: 4,
      #       unit: "tokens",
      #     },
      #   ]
      module UsageSerializer
        module Metric
          NUM_PROMPT_TOKENS = "num_prompt_tokens"
          NUM_COMPLETION_TOKENS = "num_completion_tokens"
          NUM_TOTAL_TOKENS = "num_total_tokens"
        end

        # @param data [Hash]
        #
        # @return [OmniAI::Chat::Response]
        def self.deserialize(data, *)
          prompt = data.find { |metric| metric["metric"] == Metric::NUM_PROMPT_TOKENS }
          completion = data.find { |metric| metric["metric"] == Metric::NUM_COMPLETION_TOKENS }
          total = data.find { |metric| metric["metric"] == Metric::NUM_TOTAL_TOKENS }

          input_tokens = prompt ? prompt["value"] : 0
          output_tokens = completion ? completion["value"] : 0
          total_tokens = total ? total["value"] : 0

          OmniAI::Chat::Usage.new(input_tokens:, output_tokens:, total_tokens:)
        end
      end
    end
  end
end
