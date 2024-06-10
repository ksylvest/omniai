# frozen_string_literal: true

module OmniAI
  class Chat
    # A delta returned by the API.
    class Delta
      attr_accessor :data

      # @param content [Integer]
      # @param role [String]
      def initialize(data:)
        @data = data
      end

      # @return [String, nil]
      def role
        @data['role']
      end

      # @return [String, nil]
      def content
        @data['content']
      end
    end
  end
end
