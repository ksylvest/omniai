# frozen_string_literal: true

module OmniAI
  class Chat
    # A usage returned by the API.
    class Usage
      attr_accessor :data

      # @param data [Hash]
      def initialize(data:)
        @data = data
      end

      # @return [Integer, nil]
      def completion_tokens
        @data['completion_tokens']
      end

      # @return [Integer, nil]
      def prompt_tokens
        @data['prompt_tokens']
      end

      # @return [Integer, nil]
      def total_tokens
        @data['total_tokens']
      end

      # @return [Integer, nil]
      def input_tokens
        @data['input_tokens']
      end

      # @return [Integer, nil]
      def output_tokens
        @data['output_tokens']
      end
    end
  end
end
