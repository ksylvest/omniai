# frozen_string_literal: true

module OmniAI
  class Chat
    # A choice returned by the API.
    class Choice
      attr_accessor :index, :delta, :message

      # @param data [Hash]
      # @return [OmniAI::Chat::Choice]
      def self.for(data:)
        index = data['index']
        delta = Delta.for(data: data['delta']) if data['delta']
        message = Message.for(data: data['message']) if data['message']

        new(index:, delta:, message:)
      end

      # @param data [Hash]
      def initialize(index:, delta:, message:)
        @index = index
        @delta = delta
        @message = message
      end
    end
  end
end
