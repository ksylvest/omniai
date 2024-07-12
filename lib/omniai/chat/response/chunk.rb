# frozen_string_literal: true

module OmniAI
  class Chat
    module Response
      # A chunk returned by the API.
      class Chunk < Payload
        # @return [String]
        def inspect
          "#<#{self.class.name} id=#{id.inspect} model=#{model.inspect} choices=#{choices.inspect}>"
        end

        # @return [Array<OmniAI::Chat::Response::DeltaChoice>]
        def choices
          @choices ||= @data['choices'].map { |data| DeltaChoice.new(data:) }
        end
      end
    end
  end
end
