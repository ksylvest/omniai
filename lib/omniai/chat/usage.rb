# frozen_string_literal: true

module OmniAI
  class Chat
    # An class wrapping the response usage. A vendor may override if custom behavior is required.
    class Completion
      attr_accessor :data

      # @param data [Hash]
      def initialize(data:)
        @data = data
      end

      # @return [Integer]
      def completion_tokens
        @data['completion_tokens']
      end

      # @return [Integer]
      def prompt_tokens
        @data['prompt_tokens']
      end

      # @return [Integer]
      def total_tokens
        @data['total_tokens']
      end
    end
  end
end
