# frozen_string_literal: true

module OmniAI
  class Chat
    # A completion returned by the API.
    class Completion
      attr_accessor :data

      # @param data [Hash]
      def initialize(data:)
        @data = data
      end

      # @return [String]
      def id
        @data['id']
      end

      # @return [Time]
      def created
        Time.at(@data['created']) if @data['created']
      end

      # @return [Time]
      def updated
        Time.at(@data['updated']) if @data['updated']
      end

      # @return [String]
      def model
        @data['model']
      end

      # @return [OmniAI::Chat::Usage]
      def usage
        return unless @data['usage']

        input_tokens = @data['usage']['input_tokens'] || @data['usage']['prompt_tokens']
        output_tokens = @data['usage']['output_tokens'] || @data['usage']['completion_tokens']
        total_tokens = @data['usage']['total_tokens'] || (input_tokens + output_tokens)

        @usage ||= Usage.new(
          input_tokens:,
          output_tokens:,
          total_tokens:
        )
      end

      # @return [Array<OmniAI::Chat::Choice>]
      def choices
        @choices ||= @data['choices'].map { |data| Choice.new(data:) }
      end

      # @param [index] [Integer] optional - default is 0
      # @return [OmniAI::Chat::Choice]
      def choice(index: 0)
        choices[index]
      end
    end
  end
end
