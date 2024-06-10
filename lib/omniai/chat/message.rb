# frozen_string_literal: true

module OmniAI
  class Chat
    # A message returned by the API.
    class Message
      attr_accessor :index, :message, :role

      # @param content [Integer]
      # @param role [String]
      def initialize(content:, role:)
        @content = content
        @role = role
      end
    end
  end
end
