# frozen_string_literal: true

module OmniAI
  class Chat
    # A choice wraps a message and index returned by an LLM. The default is to generate a single choice. Some LLMs
    # support generating multiple choices at once (e.g. giving you multiple options to choose from).
    class Choice
      # @return [Integer]
      attr_accessor :index

      # @return [Message]
      attr_accessor :message

      # @param message [Message]
      # @param index [Integer]
      def initialize(message:, index: 0)
        @message = message
        @index = index
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} index=#{@index} message=#{@message.inspect}>"
      end

      # @param data [Hash]
      # @param context [OmniAI::Context] optional
      #
      # @return [Choice]
      def self.deserialize(data, context: nil)
        deserialize = context&.deserializer(:choice)
        return deserialize.call(data, context:) if deserialize

        index = data['index']
        message = Message.deserialize(data['message'] || data['delta'], context:)

        new(message:, index:)
      end

      # @param context [OmniAI::Context] optional
      # @return [Hash]
      def serialize(context: nil)
        serialize = context&.serializer(:choice)
        return serialize.call(self, context:) if serialize

        {
          index:,
          message: message.serialize(context:),
        }
      end

      # @return [Message]
      def delta
        message
      end

      # @return [Array<Content>, String]
      def content
        message.content
      end

      # @return [Array<ToolCall, nil]
      def tool_call_list
        message.tool_call_list
      end
    end
  end
end
