# frozen_string_literal: true

module OmniAI
  class Chat
    # A file used for analysis.
    class Content
      attr_accessor :type, :value

      # @param url [String]
      # @param text [String]
      # @param type [Symbol] :image / :video / :audio / :text
      def initialize(value, type: :text)
        @value = value
        @type = type
      end
    end
  end
end
