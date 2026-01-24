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
      def initialize(data:, choices: [], usage: nil)
        @data = data
        @choices = choices
        @usage = usage
      end

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
      # @return [Usage, nil]
      def total_usage
        chain = response_chain
        usages = chain.map(&:usage).compact
        return nil if usages.empty?

        input_tokens = usages.sum { |u| u.input_tokens || 0 }
        output_tokens = usages.sum { |u| u.output_tokens || 0 }

        Usage.new(
          input_tokens:,
          output_tokens:,
          total_tokens: input_tokens + output_tokens
        )
      end
    end
  end
end
