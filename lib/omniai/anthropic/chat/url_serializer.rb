# frozen_string_literal: true

module OmniAI
  module Anthropic
    class Chat
      # Overrides url serialize / deserialize.
      module URLSerializer
        # @param url [OmniAI::Chat::Media]
        # @return [Hash]
        def self.serialize(url, *)
          {
            type: url.kind, # i.e. 'image' / 'video' / 'audio' / 'document' / ...
            source: {
              type: "url",
              url: url.uri,
            },
          }
        end
      end
    end
  end
end
