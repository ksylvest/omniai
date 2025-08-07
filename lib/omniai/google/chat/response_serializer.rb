# frozen_string_literal: true

module OmniAI
  module Google
    class Chat
      # Overrides response serialize / deserialize.
      module ResponseSerializer
        # @param response [OmniAI::Chat::Response]
        # @param context [OmniAI::Context]
        #
        # @return [Hash]
        def self.serialize(response, context:)
          candidates = response.choices.map { |choice| choice.serialize(context:) }
          usage_metadata = response.usage&.serialize(context:)

          {
            candidates:,
            usageMetadata: usage_metadata,
          }
        end

        # @param data [Hash]
        # @param context [OmniAI::Context]
        #
        # @return [OmniAI::Chat::Response]
        def self.deserialize(data, context:)
          choices = data["candidates"].map { |candidate| OmniAI::Chat::Choice.deserialize(candidate, context:) }
          usage = OmniAI::Chat::Usage.deserialize(data["usageMetadata"], context:) if data["usageMetadata"]

          OmniAI::Chat::Response.new(data:, choices:, usage:)
        end
      end
    end
  end
end
