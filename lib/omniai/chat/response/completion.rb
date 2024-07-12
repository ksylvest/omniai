# frozen_string_literal: true

module OmniAI
  class Chat
    module Response
      # A completion returned by the API.
      class Completion < Payload
        # @return [String]
        def inspect
          "#<#{self.class.name} id=#{id.inspect} choices=#{choices.inspect}"
        end

        # @return [Array<OmniAI::Chat:Response:::MessageChoice>]
        def choices
          @choices ||= @data['choices'].map { |data| MessageChoice.new(data:) }
        end

        # @return [Boolean]
        def tool_call_required?
          choices.any? { |choice| choice.message.tool_call_list.any? }
        end

        # @return [Array<OmniAI::Chat::Response:ToolCall>]
        def tool_call_list
          list = []
          choices.each do |choice|
            list += choice.message.tool_call_list
          end
          list
        end
      end
    end
  end
end
