# frozen_string_literal: true

module OmniAI
  class Chat
    # An class wrapping the response completion. A vendor may override if custom behavior is required.
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
        @usage ||= Usage.new(data: @data['usage']) if @data['usage']
      end

      # @return [Array<OmniAI::Chat::Choice>]
      def choices
        @choices ||= @data['choices'].map { |choice| Choice.new(data: choice) }
      end

      # @param [index] [Integer] optional - default is 0
      # @return [OmniAI::Chat::Choice]
      def choice(index: 0)
        choices[index]
      end
    end
  end
end
