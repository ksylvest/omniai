# frozen_string_literal: true

module OmniAI
  class Chat
    # For use with MessageChoice or DeltaChoice.
    class Choice < OmniAI::Chat::Response::Resource
      # @return [Integer]
      def index
        @data['index']
      end
    end
  end
end
