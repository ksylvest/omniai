# frozen_string_literal: true

module OmniAI
  class Chat
    # A normalized, provider-agnostic reason a generation stopped, paired with the verbatim provider value.
    #
    # `#reason` is one of the canonical symbols ({REASONS}) for branching/alerting; `#value` is the raw provider
    # token (e.g. "RECITATION", "end_turn", "stop"), preserved verbatim — including when the reason normalizes to
    # `:other`. Each provider maps its own vocabulary onto a reason in its deserializer; the verbatim value is never
    # discarded, so consumers keep provider granularity without digging the provider-specific response `data`.
    class FinishReason
      # A natural stopping point was reached.
      STOP = :stop

      # The token budget (requested max tokens or the model's context window) was reached.
      LENGTH = :length

      # The model is requesting a tool / function call.
      TOOL_CALL = :tool_call

      # The provider deliberately suppressed or blocked output (safety, policy, recitation, unsupported language).
      FILTER = :filter

      # A value was present but does not map to a known category (forward-compatible fallback).
      OTHER = :other

      # The canonical normalized reasons.
      REASONS = %i[stop length tool_call filter other].freeze

      # The Chat Completions `finish_reason` vocabulary (originated by OpenAI; also emitted by Mistral and
      # OpenAI-compatible gateways). Applied by the base `Choice.deserialize` path, which models that schema.
      CHAT_COMPLETIONS = {
        "stop" => STOP,
        "length" => LENGTH,
        "tool_calls" => TOOL_CALL,
        "function_call" => TOOL_CALL,
        "content_filter" => FILTER,
      }.freeze

      # @!attribute [r] reason
      #   @return [Symbol] one of {REASONS}
      attr_reader :reason

      # @!attribute [r] value
      #   @return [String] the verbatim provider token
      attr_reader :value

      # Normalizes a raw provider value through a mapping table into a FinishReason.
      #
      # - `nil` in → `nil` out (absence is not the same as unrecognized).
      # - otherwise → a FinishReason whose `reason` is the table's mapping (or `:other` when unmapped) and whose
      #   `value` is the raw token, preserved verbatim — always, including on `:other`.
      #
      # @param value [String, nil] the raw provider value
      # @param table [Hash{String => Symbol}] the provider's mapping table (defaults to the Chat Completions vocabulary)
      #
      # @return [FinishReason, nil]
      def self.deserialize(value, table: CHAT_COMPLETIONS)
        return if value.nil?

        new(reason: table.fetch(value, OTHER), value:)
      end

      # @param reason [Symbol] one of {REASONS}
      # @param value [String] the verbatim provider token
      def initialize(reason:, value:)
        @reason = reason
        @value = value
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} reason=#{reason.inspect} value=#{value.inspect}>"
      end

      # @return [Boolean]
      def stop?
        reason == STOP
      end

      # @return [Boolean]
      def length?
        reason == LENGTH
      end

      # @return [Boolean]
      def tool_call?
        reason == TOOL_CALL
      end

      # @return [Boolean]
      def filter?
        reason == FILTER
      end

      # @return [Boolean]
      def other?
        reason == OTHER
      end
    end
  end
end
