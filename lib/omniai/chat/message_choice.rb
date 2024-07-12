# frozen_string_literal: true

module OmniAI
  class Chat
    # A choice returned by the API.
    class MessageChoice < OmniAI::Chat::Choice
      # @return [OmniAI::Chat::Message]
      def message
        @message ||= Message.new(data: @data['message'])
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} index=#{index} message=#{message.inspect}>"
      end
    end
  end
end
