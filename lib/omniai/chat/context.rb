# frozen_string_literal: true

module OmniAI
  class Chat
    # Used to handle the setup of serializer / deserializer methods for each type.
    #
    # Usage:
    #
    #   OmniAI::Chat::Context.build do |context|
    #     context.serializers[:prompt] = (prompt, context:) -> { ... }
    #     context.serializers[:message] = (prompt, context:) -> { ... }
    #     context.serializers[:file] = (prompt, context:) -> { ... }
    #     context.serializers[:text] = (prompt, context:) -> { ... }
    #     context.serializers[:url] = (prompt, context:) -> { ... }
    #     context.deserializers[:prompt] = (data, context:) -> { Prompt.new(...) }
    #     context.deserializers[:message] = (data, context:) -> { Message.new(...) }
    #     context.deserializers[:file] = (data, context:) -> { File.new(...) }
    #     context.deserializers[:text] = (data, context:) -> { Text.new(...) }
    #     context.deserializers[:url] = (data, context:) -> { URL.new(...) }
    #   end
    class Context
      # @return [Hash]
      attr_accessor :serializers

      # @return [Hash]
      attr_reader :deserializers

      # @return [Context]
      def self.build(&block)
        new.tap do |context|
          block&.call(context)
        end
      end

      # @return [Context]
      def initialize
        @serializers = {}
        @deserializers = {}
      end
    end
  end
end
