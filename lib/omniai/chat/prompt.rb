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

      # @return [Prompt]
      def dup
        self.class.new(messages: @messages.dup)
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} messages=#{@messages.inspect}>"
      end

      # @return [String]
      def summarize
        @messages.map(&:summarize).join("\n\n")
      end

      # Usage:
      #
      #   prompt.serialize # => [{ content: "What is the capital of Canada?", role: :user }]
      #
      # @param context [Context] optional
      #
      # @return [Array<Hash>]
      def serialize(context: nil)
        serializer = context&.serializer(:prompt)
        return serializer.call(self, context:) if serializer

        @messages.map { |message| message.serialize(context:) }
      end

      # @example
      #   prompt.message 'What is the capital of Canada?', role: '...'
      #
      # @example
      #   prompt.message role: '...' do |message|
      #     message.text 'What is the capital of Canada?'
      #   end
      #
      # @param content [String, nil]
      # @param role [Symbol]
      #
      # @yield [builder]
      # @yieldparam builder [Message::Builder]
      #
      # @return [Message]
      def message(content = nil, role: Role::USER, &)
        Message.build(content, role:, &).tap do |message|
          @messages << message
        end
      end

      # @example
      #   prompt.system 'You are a helpful assistant.'
      #
      # @example
      #   prompt.system do |message|
      #     message.text 'You are a helpful assistant.'
      #   end
      #
      # @param content [String, nil]
      #
      # @yield [builder]
      # @yieldparam builder [Message::Builder]
      #
      # @return [Message]
      def system(content = nil, &)
        message(content, role: Role::SYSTEM, &)
      end

      # @example
      #   prompt.user('What is the capital of Canada?')
      #
      # @example
      #   prompt.user do |message|
      #     message.text 'What is the capital of Canada?'
      #     message.url 'https://...', type: "image/gif"
      #     message.file File.open('...'), type: "image/gif"
      #   end
      #
      # @param content [String, nil]
      #
      # @yield [builder]
      # @yieldparam builder [Message::Builder]
      #
      # @return [Message]
      def user(content = nil, &)
        message(content, role: Role::USER, &)
      end

      # @example
      #   prompt.assistant('the capital of Canada is Ottawa.')
      #
      # @example
      #   prompt.assistant do |message|
      #     message.text 'the capital of Canada is Ottawa.'
      #   end
      #
      # @param content [String, nil]
      #
      # @yield [builder]
      # @yieldparam builder [Message::Builder]
      #
      # @return [Message]
      def assistant(content = nil, &)
        message(content, role: Role::ASSISTANT, &)
      end
    end
  end
end
