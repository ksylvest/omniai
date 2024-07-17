# frozen_string_literal: true

module OmniAI
  class Chat
    # Used to standardize the process of building message within a prompt:
    #
    #   completion = client.chat do |prompt|
    #     prompt.user do |message|
    #       message.text 'What are these photos of?'
    #       message.url 'https://example.com/cat.jpg', type: "image/jpeg"
    #       message.url 'https://example.com/dog.jpg', type: "image/jpeg"
    #       message.file File.open('hamster.jpg'), type: "image/jpeg"
    #     end
    #   end
    class Message
      # @return [Array<Content>, String]
      attr_accessor :content

      # @return [String]
      attr_accessor :role

      # @param content [String, nil]
      # @param role [String]
      def initialize(content: nil, role: Role::USER)
        @content = content || []
        @role = role
      end

      # @return [String]
      def inspect
        "#<#{self.class} role=#{@role.inspect} content=#{@content.inspect}>"
      end

      # Usage:
      #
      #   Message.deserialize({ role: :user, content: 'Hello!' }) # => #<Message ...>
      #
      # @param data [Hash]
      # @param context [Context] optional
      #
      # @return [Message]
      def self.deserialize(data, context: nil)
        deserialize = context&.deserializers&.[](:message)
        return deserialize.call(data, context:) if deserialize

        new(
          content: data['content'].map { |content| Content.deserialize(content, context:) },
          role: data['role']
        )
      end

      # Usage:
      #
      #   message.serialize # => { role: :user, content: 'Hello!' }
      #   message.serialize # => { role: :user, content: [{ type: 'text', text: 'Hello!' }] }
      #
      # @param context [Context] optional
      #
      # @return [Hash]
      def serialize(context: nil)
        serializer = context&.serializers&.[](:message)
        return serializer.call(self, context:) if serializer

        content = @content.is_a?(String) ? @content : @content.map { |content| content.serialize(context:) }

        { role: @role, content: }
      end

      # @return [Boolean]
      def role?(role)
        String(@role).eql?(String(role))
      end

      # @return [Boolean]
      def system?
        role?(Role::SYSTEM)
      end

      # @return [Boolean]
      def user?
        role?(Role::USER)
      end

      # Usage:
      #
      #   message.text('What are these photos of?')
      #
      # @param value [String]
      #
      # @return [Text]
      def text(value)
        Text.new(value).tap do |text|
          @content << text
        end
      end

      # Usage:
      #
      #   message.url('https://example.com/hamster.jpg', type: "image/jpeg")
      #
      # @param uri [String]
      # @param type [String]
      #
      # @return [URL]
      def url(uri, type)
        URL.new(uri, type).tap do |url|
          @content << url
        end
      end

      # Usage:
      #
      #   message.file(File.open('hamster.jpg'), type: "image/jpeg")
      #
      # @param io [IO]
      # @param type [String]
      #
      # @return [File]
      def file(io, type)
        File.new(io, type).tap do |file|
          @content << file
        end
      end
    end
  end
end
