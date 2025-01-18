# frozen_string_literal: true

module OmniAI
  class Chat
    # A tool-call that includes an ID / function.
    class ToolCall
      # @return [String]
      attr_accessor :id

      # @return [Function]
      attr_accessor :function

      # @param id [String]
      # @param function [Function]
      def initialize(id:, function:)
        @id = id
        @function = function
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} id=#{id.inspect} function=#{function.inspect}>"
      end

      # @param data [Hash]
      # @param context [Context] optional
      #
      # @return [Function]
      def self.deserialize(data, context: nil)
        deserialize = context&.deserializer(:tool_call)
        return deserialize.call(data, context:) if deserialize

        id = data["id"]
        function = Function.deserialize(data["function"], context:)

        new(id:, function:)
      end

      # @param context [Context] optional
      #
      # @return [Hash]
      def serialize(context: nil)
        serializer = context&.serializer(:tool_call)
        return serializer.call(self, context:) if serializer

        {
          id: @id,
          type: "function",
          function: @function.serialize(context:),
        }
      end
    end
  end
end
