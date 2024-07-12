# frozen_string_literal: true

module OmniAI
  class Chat
    module Response
      # A completion returned by the API.
      class Completion < Payload
        # @return [Array<OmniAI::Chat:Response:::MessageChoice>]
        def choices
          @choices ||= @data['choices'].map { |data| MessageChoice.new(data:) }
        end
      end
    end
  end
end
