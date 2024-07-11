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

      # @return [Integer]
      def input_tokens
        @data['input_tokens'] || @data['prompt_tokens']
      end

      # @return [Integer]
      def output_tokens
        @data['output_tokens'] || @data['completion_tokens']
      end

      def total_tokens
        @data['total_tokens'] || (input_tokens + output_tokens)
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} input_tokens=#{input_tokens} output_tokens=#{output_tokens} total_tokens=#{total_tokens}>"
      end
    end
  end
end
