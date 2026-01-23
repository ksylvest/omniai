# frozen_string_literal: true

module OmniAI
  class Chat
    # A tool-call that includes an ID / function.
    class ToolCall
      # @!attribute [rw] id
      #   @return [String]
      attr_accessor :id

      # @!attribute [rw] function
      #   @return [Function]
      attr_accessor :function

      # @!attribute [r] options
      #   @return [Hash] provider-specific options
      attr_reader :options

      # @param id [String]
      # @param function [Function]
      # @param options [Hash] optional - used for provider-specific options
      def initialize(id:, function:, **options)
        @id = id
        @function = function
        @options = options
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
