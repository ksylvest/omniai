# frozen_string_literal: true

module OmniAI
  module Google
    class Chat
      # Overrides message serialize / deserialize.
      module MessageSerializer
        # @param message [OmniAI::Chat::Message]
        # @param context [OmniAI::Context]
        # @return [Hash]
        def self.serialize(message, context:)
          role = message.role
          parts = (arrayify(message.content) + arrayify(message.tool_call_list)).map do |part|
            case part
            when String then { text: part }
            else part.serialize(context:)
            end
          end

          { role:, parts: }
        end

        # @param data [Hash]
        # @param context [OmniAI::Context]
        # @return [OmniAI::Chat::Message]
        def self.deserialize(data, context:)
          role = data["role"]
          parts = arrayify(data["parts"]).map do |part|
            case
            when part["text"] then OmniAI::Chat::Text.deserialize(part, context:)
            when part["functionCall"] then OmniAI::Chat::ToolCall.deserialize(part, context:)
            when part["functionResponse"] then OmniAI::Chat::ToolCallResult.deserialize(part, context:)
            end
          end

          tool_call_list = parts.select { |part| part.is_a?(OmniAI::Chat::ToolCall) }
          content = parts.reject { |part| part.is_a?(OmniAI::Chat::ToolCall) }

          OmniAI::Chat::Message.new(content:, role:, tool_call_list:)
        end

        # @param content [Object]
        # @return [Array<Object>]
        def self.arrayify(content)
          return [] if content.nil?

          content.is_a?(Array) ? content : [content]
        end
      end
    end
  end
end
