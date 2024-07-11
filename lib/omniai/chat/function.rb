# frozen_string_literal: true

module OmniAI
  class Chat
    # A function returned by the API.
    class Function
      # @param data [Hash]
      def initialize(data:)
        @data = data
      end

      # @return [String]
      def name
        @data['name']
      end

      # @return [Hash, nil]
      def arguments
        JSON.parse(@data['arguments']) if @data['arguments']
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} name=#{name.inspect} arguments=#{arguments.inspect}>"
      end
    end
  end
end
