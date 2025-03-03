# frozen_string_literal: true

module OmniAI
  class Chat
    # An `OmniAI::Chat::Response` encapsulates the result of generating a chat completion.
    class Response
      # @return [Hash]
      attr_accessor :data

      # @return [Array<Choice>]
      attr_accessor :choices

      # @return [Usage, nil]
      attr_accessor :usage

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
        "#<#{self.class.name} choices=#{choices.inspect} usage=#{usage.inspect}>"
      end

      # @param data [Hash]
      # @param context [OmniAI::Context] optional
      def self.deserialize(data, context: nil)
        deserialize = context&.deserializer(:response)
        return deserialize.call(data, context:) if deserialize

        choices = data["choices"].map { |choice_data| Choice.deserialize(choice_data, context:) }
        usage = Usage.deserialize(data["usage"], context:) if data["usage"]

        new(data:, choices:, usage:)
      end

      # @param context [OmniAI::Context] optional
      # @return [Hash]
      def serialize(context:)
        serialize = context&.serializer(:response)
        return serialize.call(self, context:) if serialize

        {
          choices: choices.map { |choice| choice.serialize(context:) },
          usage: usage&.serialize(context:),
        }
      end

      # @param index [Integer]
      #
      # @return [Choice, nil]
      def choice(index: 0)
        @choices[index]
      end

      # @param index [Integer]
      #
      # @return [Boolean]
      def choice?(index: 0)
        !choice(index:).nil?
      end

      # @param index [Integer]
      #
      # @return [Message, nil]
      def message(index: 0)
        choice(index:)&.message
      end

      # @param index [Integer]
      #
      # @return [Boolean]
      def message?
        !message(index:).nil?
      end

      # @return [Array<Message>]
      def messages
        @choices.map(&:message)
      end

      # @param index [Integer]
      #
      # @return [String, nil]
      def text(index: 0)
        message(index:)&.text
      end

      # @param index [Integer]
      #
      # @return [Boolean]
      def text?(index: 0)
        message = message(index:)

        !message.nil? && message.text?
      end

      # @param index [Integer]
      #
      # @return [ToolCallList]
      def tool_call_list(index: 0)
        message(index:)&.tool_call_list
      end

      # @return [Boolean]
      def tool_call_list?(index: 0)
        tool_call_list = tool_call_list(index:)

        !tool_call_list.nil? && tool_call_list.any?
      end
    end
  end
end
