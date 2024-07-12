# frozen_string_literal: true

module OmniAI
  class Chat
    # A delta choice returned by the API.
    class DeltaChoice < OmniAI::Chat::Choice
      # @return [String]
      def inspect
        "#<#{self.class.name} index=#{index} delta=#{delta.inspect}>"
      end

      # @return [OmniAI::Chat::Response::Delta]
      def delta
        @delta ||= Response::Delta.new(data: @data['delta'])
      end
    end
  end
end
