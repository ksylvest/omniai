# frozen_string_literal: true

module OmniAI
  class Chat
    # For use with MessageChoice or DeltaChoice.
    class Choice
      # @param data [Hash]
      def initialize(data:)
        @data = data
      end

      # @return [Integer]
      def index
        @data['index']
      end
    end
  end
end
