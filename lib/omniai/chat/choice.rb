# frozen_string_literal: true

module OmniAI
  class Chat
    # A choice returned by the API.
    class Choice
      attr_accessor :data

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
        Delta.new(data: @data['delta']) if @data['delta']
      end

      # @return [OmniAI::Chat::Message]
      def message
        Message.new(data: @data['message']) if @data['message']
      end
    end
  end
end
