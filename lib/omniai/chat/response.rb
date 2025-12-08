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
    end
  end
end
