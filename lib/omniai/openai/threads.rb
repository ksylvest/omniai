# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI scope for establishing threads.
    class Threads
      # @param client [OmniAI::OpenAI::Client] required
      def initialize(client:)
        @client = client
      end

      # @param id [String] required
      def find(id:)
        Thread.find(id:, client: @client)
      end

      # @param id [String] required
      def destroy!(id:)
        Thread.destroy!(id:, client: @client)
      end

      # @param metadata [Hash] optional
      # @param tool_resources [Hash] optional
      def build(metadata: {}, tool_resources: {})
        Thread.new(metadata:, tool_resources:, client: @client)
      end
    end
  end
end
