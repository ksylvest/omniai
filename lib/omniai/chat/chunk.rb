# frozen_string_literal: true

module OmniAI
  class Chat
    # A chunk returned by the API.
    class Chunk
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

      # @return [Array<OmniAI::Chat::Choice>]
      def choices
        @choices ||= @data['choices'].map { |data| Choice.for(data:) }
      end

      # @param index [Integer]
      # @return [OmniAI::Chat::Delta]
      def choice(index: 0)
        choices[index]
      end
    end
  end
end
