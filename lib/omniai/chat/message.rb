# frozen_string_literal: true

module OmniAI
  class Chat
    # A message returned by the API.
    class Message
      attr_accessor :role, :content

      # @param data [Hash]
      # @return [OmniAI::Chat::Message]
      def self.for(data:)
        content = data['content'] || data[:content]
        role = data['role'] || data[:role]

        new(content:, role: role || Role::USER)
      end

      # @param content [String]
      # @param role [String] optional (default to "user") e.g. "assistant" / "user" / "system"
      def initialize(content:, role: OmniAI::Chat::Role::USER)
        @role = role
        @content = content
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} role=#{role.inspect} content=#{content.inspect}>"
      end
    end
  end
end
