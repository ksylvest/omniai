# frozen_string_literal: true

module OmniAI
  class Embed
    # The response returned by the API.
    class Response
      # @return [Hash]
      attr_accessor :data

      # @param data [Hash]
      # @param context [OmniAI::Context] optional
      def initialize(data:, context: nil)
        @data = data
        @context = context
      end

      # @return [String]
      def inspect
        "#<#{self.class.name}>"
      end

      # @return [Usage]
      def usage
        @usage ||= begin
          deserializer = @context&.deserializers&.[](:usage)

          if deserializer
            deserializer.call(@data, context: @context)
          else
            prompt_tokens = @data.dig('usage', 'prompt_tokens')
            total_tokens = @data.dig('usage', 'total_tokens')

            Usage.new(prompt_tokens:, total_tokens:)
          end
        end
      end

      # @param index [Integer] optional
      #
      # @return [Array<Float>]
      def embedding(index: 0)
        embeddings[index]
      end

      # @return [Array<Array<Float>>]
      def embeddings
        @embeddings ||= begin
          deserializer = @context&.deserializers&.[](:embeddings)

          if deserializer
            deserializer.call(@data, context: @context)
          else
            @data['data'].map { |embedding| embedding['embedding'] }
          end
        end
      end
    end
  end
end
