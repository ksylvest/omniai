# frozen_string_literal: true

module OmniAI
  module Anthropic
    class Chat
      # Overrides text serialize / deserialize.
      module TextSerializer
        # @param text [OmniAI::Chat::Text]
        # @return [Hash]
        def self.serialize(text, *)
          { type: "text", text: text.text }
        end

        # @param data [Hash]
        # @return [OmniAI::Chat::Text]
        def self.deserialize(data, *)
          OmniAI::Chat::Text.new(data["text"])
        end
      end
    end
  end
end
