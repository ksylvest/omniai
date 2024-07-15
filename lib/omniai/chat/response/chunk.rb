# frozen_string_literal: true

module OmniAI
  class Chat
    module Response
      # A chunk returned by the API.
      class Chunk < Payload
        # @return [Array<DeltaChoice>]
        def choices
          @choices ||= @data['choices'].map { |data| DeltaChoice.new(data:) }
        end
      end
    end
  end
end
