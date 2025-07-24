# frozen_string_literal: true

module OmniAI
  module Anthropic
    class Chat
      # Overrides file serialize / deserialize.
      module FileSerializer
        # @param media [OmniAI::Chat::Media]
        # @return [Hash]
        def self.serialize(media, *)
          {
            type: media.kind, # i.e. 'image' / 'video' / 'audio' / 'document' / ...
            source: {
              type: "base64",
              media_type: media.type, # i.e. 'image/jpeg' / 'video/ogg' / 'audio/mpeg' / ...
              data: media.data,
            },
          }
        end
      end
    end
  end
end
