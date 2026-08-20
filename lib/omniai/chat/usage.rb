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

      # The subset of `output_tokens` a provider attributes to internal reasoning ("thinking"). `nil` when the
      # provider does not report a breakdown — which is distinct from `0`, meaning the provider reported that no
      # reasoning occurred.
      #
      # @return [Integer, nil]
      attr_accessor :thinking_tokens

      # @param input_tokens [Integer]
      # @param output_tokens [Integer]
      # @param total_tokens [Integer]
      # @param thinking_tokens [Integer, nil] optional
      def initialize(input_tokens:, output_tokens:, total_tokens:, thinking_tokens: nil)
        @input_tokens = input_tokens
        @output_tokens = output_tokens
        @total_tokens = total_tokens
        @thinking_tokens = thinking_tokens
      end

      # @return [String]
      def inspect
        text = "#<#{self.class.name} input_tokens=#{input_tokens} output_tokens=#{output_tokens} " \
          "total_tokens=#{total_tokens}"
        text += " thinking_tokens=#{thinking_tokens}" unless thinking_tokens.nil?
        "#{text}>"
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
        thinking_tokens = deserialize_thinking_tokens(data)

        new(input_tokens:, output_tokens:, total_tokens:, thinking_tokens:)
      end

      # Providers that already fold reasoning into `output_tokens` report it separately as a breakdown. Anthropic
      # uses `output_tokens_details.thinking_tokens`; OpenAI uses `completion_tokens_details.reasoning_tokens`. In
      # both cases the value is a subset of the output tokens, never an addition to them.
      #
      # @param data [Hash]
      #
      # @return [Integer, nil]
      def self.deserialize_thinking_tokens(data)
        data["thinking_tokens"] ||
          data["output_tokens_details"]&.fetch("thinking_tokens", nil) ||
          data["completion_tokens_details"]&.fetch("reasoning_tokens", nil)
      end
      private_class_method :deserialize_thinking_tokens

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
        }.tap { |data| data[:thinking_tokens] = thinking_tokens unless thinking_tokens.nil? }
      end
    end
  end
end
