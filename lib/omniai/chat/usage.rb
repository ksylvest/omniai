# frozen_string_literal: true

module OmniAI
  class Chat
    # The usage of a chat in terms of tokens (input / output / total).
    class Usage
      # @return [Integer]
      attr_accessor :input_tokens

      # @return [Integer]
      attr_accessor :output_tokens

      # @return [Integer]
      attr_accessor :total_tokens

      # @param input_tokens [Integer]
      # @param output_tokens [Integer]
      # @param total_tokens [Integer]
      def initialize(input_tokens:, output_tokens:, total_tokens:)
        @input_tokens = input_tokens
        @output_tokens = output_tokens
        @total_tokens = total_tokens
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} input_tokens=#{input_tokens} output_tokens=#{output_tokens} total_tokens=#{total_tokens}>"
      end

      # @param data [Hash]
      # @param context [OmniAI::Context] optional
      #
      # @return [OmniAI::Chat::Usage]
      def self.deserialize(data, context: nil)
        deserialize = context&.deserializer(:usage)
        return deserialize.call(data, context:) if deserialize

        input_tokens = data["input_tokens"] || data["prompt_tokens"]
        output_tokens = data["output_tokens"] || data["completion_tokens"]
        total_tokens = data["total_tokens"]

        new(input_tokens:, output_tokens:, total_tokens:)
      end

      # @param context [OmniAI::Context] optional
      #
      # @return [Hash]
      def serialize(context: nil)
        serialize = context&.serializer(:usage)
        return serialize.call(self, context:) if serialize

        {
          input_tokens:,
          output_tokens:,
          total_tokens:,
        }
      end
    end
  end
end
