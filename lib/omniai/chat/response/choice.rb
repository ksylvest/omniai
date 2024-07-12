# frozen_string_literal: true

module OmniAI
  class Chat
    module Response
      # For use with MessageChoice or DeltaChoice.
      class Choice < Resource
        # @return [Integer]
        def index
          @data['index']
        end
      end
    end
  end
end
