# frozen_string_literal: true

module OmniAI
  class Chat
    # A choice returned by the API.
    class MessageChoice < Response::Choice
      # @return [String]
      def inspect
        "#<#{self.class.name} index=#{index} message=#{message.inspect}>"
      end

      # @return [OmniAI::Chat::Response::Message]
      def message
        @message ||= Response::Message.new(data: @data['message'])
      end
    end
  end
end
