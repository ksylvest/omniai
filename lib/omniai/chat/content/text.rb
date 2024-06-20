# frozen_string_literal: true

module OmniAI
  class Chat
    module Content
      # Just some text.
      class Text
        attr_accessor :text

        # @param text [text]
        def initialize(text)
          @text = text
        end
      end
    end
  end
end
