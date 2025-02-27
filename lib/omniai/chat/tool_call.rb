# frozen_string_literal: true

module OmniAI
  class Chat
    # A tool-call that includes an ID / function.
    class ToolCall
      DEFAULT_INDEX = 0

      # @!attribute [rw] id
      #   @return [String]
      attr_accessor :id

      # @!attribute [rw] index
      #   @return [Integer]
      attr_accessor :index

      # @!attribute [rw] function
      #   @return [Function]
      attr_accessor :function

      # @param id [String]
      # @param index [Integer]
      # @param function [Function]
      def initialize(id:, function:, index: DEFAULT_INDEX)
        @id = id
        @index = index
        @function = function
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} id=#{id.inspect} function=#{function.inspect}>"
      end

      # @param data [Hash]
      # @param context [Context] optional
      #
      # @return [ToolCall]
      def self.deserialize(data, context: nil)
        deserialize = context&.deserializer(:tool_call)
        return deserialize.call(data, context:) if deserialize

        id = data["id"]
        index = data["index"] || DEFAULT_INDEX
        function = Function.deserialize(data["function"], context:)

        new(id:, index:, function:)
      end

      # @param context [Context] optional
      #
      # @return [Hash]
      def serialize(context: nil)
        serializer = context&.serializer(:tool_call)
        return serializer.call(self, context:) if serializer

        {
          id: @id,
          index: @index,
          type: "function",
          function: @function.serialize(context:),
        }
      end
    end
  end
end
