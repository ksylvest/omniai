# frozen_string_literal: true

module OmniAI
  module Google
    class Chat
      # Overrides choice serialize / deserialize.
      module ChoiceSerializer
        # @param choice [OmniAI::Chat::Choice]
        # @param context [Context]
        # @return [Hash]
        def self.serialize(choice, context:)
          content = choice.message.serialize(context:)
          { content: }
        end

        # @param data [Hash]
        # @param context [Context]
        # @return [OmniAI::Chat::Choice]
        def self.deserialize(data, context:)
          message = OmniAI::Chat::Message.deserialize(data["content"], context:)
          OmniAI::Chat::Choice.new(message:)
        end
      end
    end
  end
end
