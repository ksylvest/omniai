# frozen_string_literal: true

module OmniAI
  class Chat
    # A usage returned by the API.
    class Usage
      attr_accessor :input_tokens, :output_tokens, :total_tokens

      # @param input_tokens [Integer]
      # @param output_tokens [Integer]
      # @param total_tokens [Integer]
      def initialize(input_tokens:, output_tokens:, total_tokens:)
        @input_tokens = input_tokens
        @output_tokens = output_tokens
        @total_tokens = total_tokens
      end

      # @return [Integer]
      def completion_tokens
        @output_tokens
      end

      # @return [Integer]
      def prompt_tokens
        @input_tokens
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} input_tokens=#{input_tokens} output_tokens=#{output_tokens} total_tokens=#{total_tokens}>"
      end
    end
  end
end
