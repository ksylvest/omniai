# frozen_string_literal: true

module OmniAI
  class Chat
    # A tool-call returned by the API.
    class ToolCall
      # @param data [Hash]
      def initialize(data:)
        @data = data
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

      # @return [String]
      def inspect
        "#<#{self.class.name} id=#{id.inspect} type=#{type.inspect}>"
      end
    end
  end
end
