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
      def initialize(choices: [], usage: nil)
        @id = SecureRandom.alphanumeric
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
        deserialize = context&.deserializer(:payload)
        return deserialize.call(data, context:) if deserialize

        choices = data["choices"].map { |choice_data| Choice.deserialize(choice_data, context:) }
        usage = Usage.deserialize(data["usage"], context:) if data["usage"]

        new(choices:, usage:)
      end

      # @param context [OmniAI::Context] optional
      # @return [Hash]
      def serialize(context:)
        serialize = context&.serializer(:payload)
        return serialize.call(self, context:) if serialize

        {
          choices: choices.map { |choice| choice.serialize(context:) },
          usage: usage&.serialize(context:),
        }
      end

      # @param other [OmniAI::Chat::Payload]
      def merge!(other)
        return unless other

        @usage = other.usage if other.usage

        other.choices.each do |choice|
          if choice?(index: choice.index)
            choices[choice.index] = choices[choice.index].merge(choice)
          else
            @choices[choice.index] = choice
          end
        end
      end

      # @param index [Integer]
      # @return [Choice]
      def choice(index: 0)
        @choices[index]
      end

      # @param index [Integer]
      # @return [Boolean]
      def choice?(index: 0)
        !choice(index:).nil?
      end

      # @param index [Integer]
      # @return [Message]
      def message(index: 0)
        choice(index:).message
      end

      # @return [Array<Message>]
      def messages
        @choices.map(&:message)
      end

      # @param index [Integer]
      # @return [String, nil]
      def text(index: 0)
        message(index:).text
      end

      # @param index [Integer]
      # @return [Boolean]
      def text?(index: 0)
        message(index:).text?
      end

      # @param index [Integer]
      # @return [Array<ToolCall>]
      def tool_call_list(index:)
        message(index:).tool_call_list
      end
    end
  end
end
