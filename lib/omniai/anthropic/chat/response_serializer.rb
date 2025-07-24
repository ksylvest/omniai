# frozen_string_literal: true

module OmniAI
  module Anthropic
    class Chat
      # Overrides response serialize / deserialize.
      module ResponseSerializer
        # @param response [OmniAI::Chat::Response]
        # @param context [OmniAI::Context]
        #
        # @return [Hash]
        def self.serialize(response, context:)
          usage = response.usage.serialize(context:)
          choice = response.choice.serialize(context:)

          choice.merge({ usage: })
        end

        # @param data [Hash]
        # @param context [OmniAI::Context]
        #
        # @return [OmniAI::Chat::Response]
        def self.deserialize(data, context:)
          usage = OmniAI::Chat::Usage.deserialize(data["usage"], context:) if data["usage"]
          choice = OmniAI::Chat::Choice.deserialize(data, context:)

          OmniAI::Chat::Response.new(data:, choices: [choice], usage:)
        end
      end
    end
  end
end
