# frozen_string_literal: true

module OmniAI
  class Chat
    # A function that includes a name / arguments.
    class Function
      # @return [String]
      attr_accessor :name

      # @return [String]
      attr_accessor :arguments

      # @param name [String]
      # @param arguments [String]
      def initialize(name:, arguments:)
        @name = name
        @arguments = arguments
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} name=#{name.inspect} arguments=#{arguments.inspect}>"
      end

      # @param other [Function]
      def merge(other)
        self.class.new(name: @name, arguments: @arguments + other.arguments)
      end

      # @return [Hash]
      def arguments!
        return {} if @arguments.nil? || @arguments.empty?
        return @arguments unless @arguments.is_a?(String)

        JSON.parse(@arguments)
      rescue JSON::ParserError
        @arguments
      end

      # @param data [Hash]
      # @param context [Context] optional
      #
      # @return [Function]
      def self.deserialize(data, context: nil)
        deserialize = context&.deserializer(:function)
        return deserialize.call(data, context:) if deserialize

        name = data["name"]
        arguments = data["arguments"]

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
          arguments: @arguments,
        }
      end
    end
  end
end
