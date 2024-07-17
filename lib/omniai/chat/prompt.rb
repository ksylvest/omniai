# frozen_string_literal: true

module OmniAI
  class Chat
    # Used to standardizes the process of building complex prompts.
    #
    # Usage:
    #
    #   completion = OmniAI::Chat::Prompt.build do |prompt|
    #     prompt.system('You are a helpful assistant.')
    #     prompt.user do |message|
    #       message.text 'What are these photos of?'
    #       message.url 'https://example.com/cat.jpg', type: "image/jpeg"
    #       message.url 'https://example.com/dog.jpg', type: "image/jpeg"
    #       message.file File.open('hamster.jpg'), type: "image/jpeg"
    #     end
    #   end
    class Prompt
      class MessageError < Error; end

      # @return [Array<Message>]
      attr_accessor :messages

      # Usage:
      #
      #   OmniAI::Chat::Prompt.build do |prompt|
      #     prompt.system('You are an expert in geography.')
      #     prompt.user('What is the capital of Canada?')
      #   end
      #
      # @return [Prompt]
      # @yield [Prompt]
      def self.build(&block)
        new.tap do |prompt|
          block&.call(prompt)
        end
      end

      # Usage:
      #
      #   OmniAI::Chat::Prompt.parse('What is the capital of Canada?')
      #
      # @param prompt [nil, String]
      #
      # @return [Prompt]
      def self.parse(prompt)
        new if prompt.nil?
        return prompt if prompt.is_a?(self)

        new.tap do |instance|
          instance.user(prompt)
        end
      end

      # @param messages [Array<Message>] optional
      def initialize(messages: [])
        @messages = messages
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} messages=#{@messages.inspect}>"
      end

      # Usage:
      #
      #   prompt.serialize # => [{ content: "What is the capital of Canada?", role: :user }]
      #
      # @param context [Context] optional
      #
      # @return [Array<Hash>]
      def serialize(context: nil)
        serializer = context&.serializers&.[](:prompt)
        return serializer.call(self, context:) if serializer

        @messages.map { |message| message.serialize(context:) }
      end

      # Usage:
      #
      #   prompt.message('What is the capital of Canada?')
      #
      # @param content [String, nil]
      # @param role [Symbol]
      #
      # @yield [Message]
      # @return [Message]
      def message(content = nil, role: :user, &block)
        raise ArgumentError, 'content or block is required' if content.nil? && block.nil?

        Message.new(content:, role:).tap do |message|
          block&.call(message)
          @messages << message
        end
      end

      # Usage:
      #
      #   prompt.system('You are a helpful assistant.')
      #
      #   prompt.system do |message|
      #     message.text 'You are a helpful assistant.'
      #   end
      #
      # @param content [String, nil]
      #
      # @yield [Message]
      # @return [Message]
      def system(content = nil, &)
        message(content, role: Role::SYSTEM, &)
      end

      # Usage:
      #
      #   prompt.user('What is the capital of Canada?')
      #
      #   prompt.user do |message|
      #     message.text 'What is the capital of Canada?'
      #   end
      #
      # @param content [String, nil]
      #
      # @yield [Message]
      # @return [Message]
      def user(content = nil, &)
        message(content, role: Role::USER, &)
      end
    end
  end
end
