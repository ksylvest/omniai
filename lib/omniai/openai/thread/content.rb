# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Thread
      # An OpenAI content w/ annotations.
      class Content
        module Type
          TEXT = "text"
        end

        # @param data [Array]
        # @param client [OmniAI::OpenAI::Client]
        #
        # @return [Array<OmniAI::OpenAI::Thread::Content>, String, nil]
        def self.for(data:, client: Client.new)
          return data unless data.is_a?(Enumerable)

          data.map { |attachment| new(data: attachment, client:) }
        end

        # @!attribute [rw] data
        #   @return [Hash, nil]
        attr_accessor :data

        # @param data [Hash]
        def initialize(data:, client:)
          @data = data
          @client = client
        end

        # @return [String] e.g. "text"
        def type
          @type ||= @data["type"]
        end

        # @return [Boolean]
        def text?
          type.eql?(Type::TEXT)
        end

        # @return [OmniAI::OpenAI::Thread::Text]
        def text
          @text ||= Text.new(data: @data["text"], client: @client) if @data["text"]
        end
      end
    end
  end
end
