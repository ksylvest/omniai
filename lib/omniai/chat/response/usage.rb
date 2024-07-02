# frozen_string_literal: true

module OmniAI
  class Chat
    module Response
      # A usage returned by the API.
      class Usage
        attr_accessor :input_tokens, :output_tokens, :total_tokens

        # @param data [Hash]
        # @return [OmniAI::Chat::Usage]
        def self.for(data:)
          input_tokens = data['input_tokens'] || data['prompt_tokens']
          output_tokens = data['output_tokens'] || data['completion_tokens']
          total_tokens = data['total_tokens'] || (input_tokens + output_tokens)

          new(
            input_tokens:,
            output_tokens:,
            total_tokens:
          )
        end

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
          props = [
            "input_tokens=#{@input_tokens}",
            "output_tokens=#{@output_tokens}",
            "total_tokens=#{@total_tokens}",
          ]
          "#<#{self.class.name} #{props.join(' ')}>"
        end
      end
    end
  end
end
