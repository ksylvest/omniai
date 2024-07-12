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

        # @return [Boolean]
        def tool_call_required?
          part.tool_call_required?
        end
      end
    end
  end
end
