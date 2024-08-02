# frozen_string_literal: true

module OmniAI
  class Embed
    # Token usage returned by the API.
    class Usage
      # @return [Integer]
      attr_accessor :prompt_tokens

      # @return [Integer]
      attr_accessor :total_tokens

      # @param prompt_tokens Integer
      # @param total_tokens Integer
      def initialize(prompt_tokens:, total_tokens:)
        @prompt_tokens = prompt_tokens
        @total_tokens = total_tokens
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} prompt_tokens=#{@prompt_tokens} total_tokens=#{@total_tokens}>"
      end
    end
  end
end
