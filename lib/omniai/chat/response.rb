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

      # @return [Usage, nil]
      def usage
        completion.usage
      end

      # @return [Array<Choice>]
      def choices
        completion.choices
      end

      # @return [Array<Message>]
      def messages
        completion.messages
      end

      # @param index [Integer]
      # @return [Choice]
      def choice(index: 0)
        completion.choice(index:)
      end

      # @param index [Integer]
      # @return [Message]
      def message(index: 0)
        completion.message(index:)
      end

      # @return [String]
      def text
        message.text
      end

      # @return [Boolean]
      def text?
        message.text?
      end

      # @return [Array<ToolCall>]
      def tool_call_list
        choice.tool_call_list
      end

      # @return [Boolean]
      def tool_call_list?
        tool_call_list&.any?
      end
    end
  end
end
