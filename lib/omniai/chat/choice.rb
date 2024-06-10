# frozen_string_literal: true

module OmniAI
  class Chat
    # A choice returned by the API.
    class Choice
      attr_accessor :index, :message, :role

      # @param index [Integer]
      # @param message [OmniAI::Chat::Message]
      # @param role [String]
      def initialize(index:, message:)
        @index = index
        @message = message
      end
    end
  end
end
