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

        # @return [OmniAI::Chat::Response::Part]
        def part
          raise NotImplementedError, "#{self.class.name}#part undefined"
        end

        # @return [OmniAI::Chat::Response::ToolCallList]
        def tool_call_list
          part.tool_call_list
        end

        # @return [String, nil]
        def content
          part.content
        end

        # @return [Boolean]
        def content?
          !content.nil?
        end
      end
    end
  end
end
