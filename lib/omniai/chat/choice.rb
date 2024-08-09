# frozen_string_literal: true

module OmniAI
  class Chat
    # For for.
    class Choice
      # @return [Integer]
      attr_accessor :index

      # @return [Message]
      attr_accessor :message

      # @param message [Message]
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
        deserialize = context&.deserializers&.[](:choice)
        return deserialize.call(data, context:) if deserialize

        index = data['index']
        message = Message.deserialize(data['message'] || data['delta'], context:)
        new(message:, index:)
      end

      # @param context [OmniAI::Context] optional
      # @return [Hash]
      def serialize(context: nil)
        serialize = context&.serializers&.[](:choice)
        return serialize.call(self, context:) if serialize

        {
          index:,
          message: message.serialize(context:),
        }
      end
    end
  end
end
