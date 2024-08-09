# frozen_string_literal: true

module OmniAI
  class Chat
    # A chunk or completion.
    class Payload
      # @return [Array<Choice>]
      attr_accessor :choices

      # @return [Usage, nil]
      attr_accessor :usage

      # @param choices [Array<Choice>]
      # @param usage [Usage, nil]
      def initialize(choices:, usage: nil)
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
        deserialize = context&.deserializers&.[](:payload)
        return deserialize.call(data, context:) if deserialize

        choices = data['choices'].map { |choice_data| Choice.deserialize(choice_data, context:) }
        usage = Usage.deserialize(data['usage'], context:) if data['usage']

        new(choices:, usage:)
      end

      # @param context [OmniAI::Context] optional
      # @return [Hash]
      def serialize(context:)
        serialize = context&.serializers&.[](:payload)
        return serialize.call(self, context:) if serialize

        {
          choices: choices.map { |choice| choice.serialize(context:) },
          usage: usage&.serialize(context:),
        }
      end

      # @param index [Integer]
      # @return [Choice]
      def choice(index: 0)
        choices[index]
      end

      # @param index [Integer]
      # @return [Message]
      def message(index: 0)
        choice(index:).message
      end

      # @return [String, nil]
      def content(index: 0)
        message(index:).content
      end

      # @return [Boolean]
      def content?(index: 0)
        message(index:).content?
      end

      # @return [Array<ToolCall>]
      def tool_call_list
        choice.tool_call_list
      end
    end
  end
end
