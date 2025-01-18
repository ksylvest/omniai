# frozen_string_literal: true

module OmniAI
  class Chat
    # A function that includes a name / arguments.
    class Function
      # @return [String]
      attr_accessor :name

      # @return [Hash]
      attr_accessor :arguments

      # @param name [String]
      # @param arguments [Hash]
      def initialize(name:, arguments:)
        @name = name
        @arguments = arguments
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} name=#{name.inspect} arguments=#{arguments.inspect}>"
      end

      # @param data [Hash]
      # @param context [Context] optional
      #
      # @return [Function]
      def self.deserialize(data, context: nil)
        deserialize = context&.deserializer(:function)
        return deserialize.call(data, context:) if deserialize

        name = data["name"]
        arguments = begin
          JSON.parse(data["arguments"]) if data["arguments"]
        rescue JSON::ParserError
          data["arguments"]
        end

        new(name:, arguments:)
      end

      # @param context [Context] optional
      #
      # @return [Hash]
      def serialize(context: nil)
        serializer = context&.serializer(:function)
        return serializer.call(self, context:) if serializer

        {
          name: @name,
          arguments: (JSON.generate(@arguments) if @arguments),
        }
      end
    end
  end
end
