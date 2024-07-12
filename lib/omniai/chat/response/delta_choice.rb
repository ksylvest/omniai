# frozen_string_literal: true

module OmniAI
  class Chat
    module Response
      # A delta choice returned by the API.
      class DeltaChoice < Choice
        # @return [String]
        def inspect
          "#<#{self.class.name} index=#{index} delta=#{delta.inspect}>"
        end

        # @return [OmniAI::Chat::Response::Delta]
        def delta
          @delta ||= Delta.new(data: @data['delta'])
        end
      end
    end
  end
end
