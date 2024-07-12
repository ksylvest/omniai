# frozen_string_literal: true

module OmniAI
  class Chat
    module Response
      # A choice returned by the API.
      class MessageChoice < Choice
        # @return [String]
        def inspect
          "#<#{self.class.name} index=#{index} message=#{message.inspect}>"
        end

        # @return [OmniAI::Chat::Response::Message]
        def message
          @message ||= Message.new(data: @data['message'])
        end

        # @return [OmniAI::Chat::Response::Message]
        def part
          message
        end
      end
    end
  end
end
