# frozen_string_literal: true

module OmniAI
  class Chat
    # A tool-call returned by the API.
    class ToolCall < OmniAI::Chat::Response::Resource
      # @return [String]
      def inspect
        "#<#{self.class.name} id=#{id.inspect} type=#{type.inspect}>"
      end

      # @return [String]
      def id
        @data['id']
      end

      # @return [String]
      def type
        @data['type']
      end

      # @return [OmniAI::Chat::Function]
      def function
        @function ||= Function.new(data: @data['function']) if @data['function']
      end
    end
  end
end
