# frozen_string_literal: true

module OmniAI
  class Chat
    # A function returned by the API.
    class Function < OmniAI::Chat::Response::Resource
      # @return [String]
      def inspect
        "#<#{self.class.name} name=#{name.inspect} arguments=#{arguments.inspect}>"
      end

      # @return [String]
      def name
        @data['name']
      end

      # @return [Hash, nil]
      def arguments
        JSON.parse(@data['arguments']) if @data['arguments']
      end
    end
  end
end
