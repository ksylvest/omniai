# frozen_string_literal: true

module OmniAI
  class Chat
    # A delta returned by the API.
    class Delta
      # @param data [Hash]
      def initialize(data:)
        @data = data
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} role=#{role.inspect} content=#{content.inspect}>"
      end

      # @return [String, nil]
      def content
        @data['content']
      end

      # @return [String]
      def role
        @data['role'] || Role::USER
      end
    end
  end
end
