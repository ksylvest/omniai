# frozen_string_literal: true

module OmniAI
  # Used to handle the setup of serializer / deserializer required per provide (e.g. Anthropic / Google / etc).
  #
  # Usage:
  #
  #   OmniAI::Context.build do |context|
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

    # @yield [context]
    # @yieldparam context [Context]
    #
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

    # @param name [Symbol]
    # @return [Proc, nil]
    def serializer(name)
      @serializers[name]
    end

    # @param name [Symbol]
    # @return [Proc, nil]
    def deserializer(name)
      @deserializers[name]
    end
  end
end
