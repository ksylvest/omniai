# frozen_string_literal: true

module OmniAI
  class Chat
    # A message returned by the API.
    class Message
      attr_accessor :data

      # @param content [Integer]
      # @param role [String]
      def initialize(data:)
        @data = data
      end

      # @return [String]
      def role
        @data['role']
      end

      # @return [String]
      def content
        @data['content']
      end
    end
  end
end
