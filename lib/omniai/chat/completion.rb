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

        @usage ||= Usage.for(data: @data['usage'])
      end

      # @return [Array<OmniAI::Chat::Choice>]
      def choices
        @choices ||= @data['choices'].map { |data| Choice.for(data:) }
      end

      # @param index [Integer] optional - default is 0
      # @return [OmniAI::Chat::Choice]
      def choice(index: 0)
        choices[index]
      end
    end
  end
end
