# frozen_string_literal: true

module OmniAI
  class Chat
    # A delta choice returned by the API.
    class DeltaChoice
      # @param data [Hash]
      def initialize(data:)
        @data = data
      end

      # @return [Integer]
      def index
        @data['index']
      end

      # @return [OmniAI::Chat::Delta]
      def delta
        @delta ||= Delta.new(data: @data['delta'])
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} index=#{index} delta=#{delta.inspect}>"
      end
    end
  end
end
