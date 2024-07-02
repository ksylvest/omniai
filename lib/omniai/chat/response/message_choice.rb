# frozen_string_literal: true

module OmniAI
  class Chat
    module Response
      # A message choice returned by the API.
      class MessageChoice
        attr_accessor :index, :message

        # @param data [Hash]
        # @return [OmniAI::Chat::Choice]
        def self.for(data:)
          index = data['index']
          message = Message.for(data: data['message'])

          new(index:, message:)
        end

        # @param index [Integer]
        # @param message [OmniAI::Chat::Message]
        def initialize(index:, message:)
          @index = index
          @message = message
        end

        # @return [String]
        def inspect
          "#<#{self.class.name} index=#{@index} message=#{@message.inspect}>"
        end
      end
    end
  end
end
