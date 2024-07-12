# frozen_string_literal: true

module OmniAI
  class Chat
    # A usage returned by the API.
    class Usage < OmniAI::Chat::Response::Resource
      # @return [String]
      def inspect
        properties = [
          "input_tokens=#{input_tokens}",
          "output_tokens=#{output_tokens}",
          "total_tokens=#{total_tokens}",
        ]
        "#<#{self.class.name} #{properties.join(' ')}>"
      end

      # @return [Integer]
      def input_tokens
        @data['input_tokens'] || @data['prompt_tokens']
      end

      # @return [Integer]
      def output_tokens
        @data['output_tokens'] || @data['completion_tokens']
      end

      # @return [Integer]
      def total_tokens
        @data['total_tokens'] || (input_tokens + output_tokens)
      end
    end
  end
end
