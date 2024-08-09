# frozen_string_literal: true

module OmniAI
  class Chat
    class Message
      # Used to build a message.
      class Builder
        # @param role [String]
        # @return [Message]
        def self.build(role:)
          builder = new(role:)
          yield(builder)
          builder.build
        end

        # @param role [String]
        def initialize(role: Role::USER)
          @role = role
          @content = []
        end

        # @return [Message]
        def build
          Message.new(content: @content, role: @role)
        end

        # @example
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

        # @example
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

        # @example
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
end
