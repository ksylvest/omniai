# frozen_string_literal: true

module OmniAI
  class Chat
    # A delta choice returned by the API.
    class DeltaChoice
      attr_accessor :index, :delta

      # @param data [Hash]
      # @return [OmniAI::Chat::Choice]
      def self.for(data:)
        index = data['index']
        delta = Delta.for(data: data['delta'])

        new(index:, delta:)
      end

      # @param index [Integer]
      # @param delta [Delta]
      def initialize(index:, delta:)
        @index = index
        @delta = delta
      end
    end
  end
end
