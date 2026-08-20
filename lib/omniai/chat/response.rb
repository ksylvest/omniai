# frozen_string_literal: true

module OmniAI
  class Chat
    # An `OmniAI::Chat::Response` encapsulates the result of generating a chat completion.
    class Response
      # @!attribute [data]
      #   @return [Hash]
      attr_accessor :data

      # @!attribute [usage]
      #   @return [Usage, nil]
      attr_accessor :usage

      # @!attribute [choices]
      #   @return [Array<Choice>]
      attr_accessor :choices

      # @!attribute [parent]
      #   @return [Response, nil] the parent response in a tool call chain
      attr_accessor :parent

      # @param data [Hash]
      # @param choices [Array<Choice>]
      # @param usage [Usage, nil]
      # @param finish_reason [FinishReason, nil] an optional response-level finish reason (used by providers that
      #   expose it at the response level, e.g. OpenAI's Responses API); when omitted, `#finish_reason` falls back to
      #   the first choice's finish reason.
      def initialize(data:, choices: [], usage: nil, finish_reason: nil)
        @data = data
        @choices = choices
        @usage = usage
        @finish_reason = finish_reason
      end

      # The normalized {FinishReason} for the final turn (carrying both `#reason` and the verbatim provider `#value`),
      # or `nil` when absent. Some providers (e.g. OpenAI's Responses API) expose this at the response level; most
      # expose it per-choice. Prefers an explicit response-level value, then falls back to the first choice. Reflects
      # this response only (the final turn) — it is not aggregated across the parent chain, unlike {#total_usage}.
      #
      # @return [FinishReason, nil]
      def finish_reason
        @finish_reason || @choices.first&.finish_reason
      end

      # @!attribute [w] finish_reason
      attr_writer :finish_reason

      # @return [String]
      def inspect
        "#<#{self.class.name} choices=#{@choices.inspect} usage=#{@usage.inspect}>"
      end

      # @param data [Hash]
      # @param context [OmniAI::Context] optional
      #
      # @return [OmniAI::Chat::Response]
      def self.deserialize(data, context: nil)
        deserialize = context&.deserializer(:response)
        return deserialize.call(data, context:) if deserialize

        choices = data["choices"].map { |choice_data| Choice.deserialize(choice_data, context:) }
        usage = Usage.deserialize(data["usage"], context:) if data["usage"]

        new(data:, choices:, usage:)
      end

      # @param context [OmniAI::Context] optional
      #
      # @return [Hash]
      def serialize(context:)
        serialize = context&.serializer(:response)
        return serialize.call(self, context:) if serialize

        {
          choices: @choices.map { |choice| choice.serialize(context:) },
          usage: @usage&.serialize(context:),
        }
      end

      # @return [Array<Message>]
      def messages
        @choices.map(&:message).compact
      end

      # @return [Boolean]
      def messages?
        messages.any?
      end

      # @return [String, nil]
      def text
        return unless text?

        messages.filter(&:text?).map(&:text).join("\n\n")
      end

      # @return [Boolean]
      def text?
        messages.any?(&:text?)
      end

      # @return [String, nil]
      def thinking
        return unless thinking?

        messages.filter(&:thinking?).map(&:thinking).join("\n\n")
      end

      # @return [Boolean]
      def thinking?
        messages.any?(&:thinking?)
      end

      # @return [ToolCallList, nil]
      def tool_call_list
        tool_call_lists = messages.filter(&:tool_call_list?).map(&:tool_call_list)
        return if tool_call_lists.empty?

        tool_call_lists.reduce(&:+)
      end

      # @return [Boolean]
      def tool_call_list?
        !tool_call_list.nil?
      end

      # Links this response chain to a parent response.
      # Walks up to find the oldest response (no parent) and sets its parent.
      #
      # @param parent [Response]
      def link_to(parent)
        current = self
        current = current.parent while current.parent
        current.parent = parent
      end

      # Returns the chain of responses from oldest (first) to newest (self).
      #
      # @return [Array<Response>]
      def response_chain
        chain = []
        current = self

        while current
          chain.unshift(current)
          current = current.parent
        end

        chain
      end

      # Returns aggregated usage across all responses in the chain.
      # Walks the parent chain and sums all token counts.
      #
      # `total_tokens` prefers each response's provider-reported total and only falls back to `input + output` for
      # responses where the provider reported none. Summing the reported totals matters wherever a provider counts
      # tokens that are neither input nor output — Google's `totalTokenCount` includes thinking tokens, so
      # recomputing unconditionally would discard them.
      #
      # Known limitation: Anthropic reports no total at all, so its contribution is always the derived
      # `input + output`, which excludes `cache_creation_input_tokens` and `cache_read_input_tokens`. An aggregate
      # spanning Anthropic responses therefore understates cache-heavy conversations.
      #
      # @return [Usage, nil]
      def total_usage
        usages = response_chain.map(&:usage).compact
        return nil if usages.empty?

        input_tokens = usages.sum { |usage| usage.input_tokens || 0 }
        output_tokens = usages.sum { |usage| usage.output_tokens || 0 }
        total_tokens = usages.sum do |usage|
          usage.total_tokens || ((usage.input_tokens || 0) + (usage.output_tokens || 0))
        end

        thinking = usages.filter_map(&:thinking_tokens)
        thinking_tokens = thinking.sum unless thinking.empty?

        Usage.new(input_tokens:, output_tokens:, total_tokens:, thinking_tokens:)
      end
    end
  end
end
