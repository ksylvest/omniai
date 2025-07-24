# frozen_string_literal: true

module OmniAI
  module Google
    class Chat
      # Overrides usage serialize / deserialize.
      module UsageSerializer
        # @param usage [OmniAI::Chat::Usage]
        # @return [Hash]
        def self.serialize(usage, *)
          {
            promptTokenCount: usage.input_tokens,
            candidatesTokenCount: usage.output_tokens,
            totalTokenCount: usage.total_tokens,
          }
        end

        # @param data [Hash]
        # @return [OmniAI::Chat::Usage]
        def self.deserialize(data, *)
          input_tokens = data["promptTokenCount"]
          output_tokens = data["candidatesTokenCount"]
          total_tokens = data["totalTokenCount"]
          OmniAI::Chat::Usage.new(input_tokens:, output_tokens:, total_tokens:)
        end
      end
    end
  end
end
