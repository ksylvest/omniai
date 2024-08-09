# frozen_string_literal: true

module OmniAI
  class Chat
    # Used when processing everything at once.
    class Response
      # @return [Hash]
      attr_accessor :data

      # @param data [Hash]
      # @param context [Context, nil]
      def initialize(data:, context: nil)
        @data = data
        @context = context
      end

      # @return [Payload]
      def completion
        @completion ||= Payload.deserialize(@data, context: @context)
      end

      # @return [String]
      def content
        completion.content
      end
    end
  end
end
