# frozen_string_literal: true

module OmniAI
  class Chat
    module Response
      # A delta returned by the API.
      class Delta
        attr_accessor :role, :content

        # @param data [Hash]
        # @return [OmniAI::Chat::Message]
        def self.for(data:)
          content = data['content'] || data[:content]
          role = data['role'] || data[:role]

          new(content:, role: role || Role::USER)
        end

        # @param content [String]
        # @param role [String]
        def initialize(content:, role: nil)
          @content = content
          @role = role
        end

        # @return [String]
        def inspect
          "#<#{self.class.name} role=#{@role.inspect} content=#{@content.inspect}>"
        end
      end
    end
  end
end
