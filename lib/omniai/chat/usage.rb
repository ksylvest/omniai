# frozen_string_literal: true

module OmniAI
  class Chat
    # The usage of a chat in terms of tokens (input / output / total).
    #
    # Two invariants hold across every provider:
    #
    # - `thinking_tokens` is a *subset* of `output_tokens`, never an addition to it. Providers either fold reasoning
    #   into their output count already (reporting the breakdown separately) or report it separately and have it
    #   added in by their own serializer. Adding `thinking_tokens` to `output_tokens` double counts.
    # - `total_tokens` may exceed `input_tokens + output_tokens`. Providers count buckets this class does not model
    #   — cached input, tool-use prompts — so the reported total is authoritative and is never recomputed from the
    #   parts. It may also be `nil`: some providers report no total at all.
    #
    # Provider-specific vocabulary is read by that provider's own `:usage` deserializer, not here. This class reads
    # only its own keys and the flat OpenAI-compatible aliases the base client speaks.
    class Usage
      # @return [Integer, nil]
      attr_accessor :input_tokens

      # @return [Integer, nil]
      attr_accessor :output_tokens

      # @return [Integer, nil]
      attr_accessor :total_tokens

      # The subset of `output_tokens` a provider attributes to internal reasoning ("thinking"). `nil` when the
      # provider does not report a breakdown — which is distinct from `0`, meaning the provider reported that no
      # reasoning occurred.
      #
      # @return [Integer, nil]
      attr_accessor :thinking_tokens

      # @param input_tokens [Integer, nil]
      # @param output_tokens [Integer, nil]
      # @param total_tokens [Integer, nil]
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
        thinking_tokens = data["thinking_tokens"]

        new(input_tokens:, output_tokens:, total_tokens:, thinking_tokens:)
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
        }.tap { |data| data[:thinking_tokens] = thinking_tokens unless thinking_tokens.nil? }
      end
    end
  end
end
