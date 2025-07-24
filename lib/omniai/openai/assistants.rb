# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI scope for establishing assistants.
    class Assistants
      # @param client [OmniAI::OpenAI::Client] required
      def initialize(client:)
        @client = client
      end

      # @param id [String] required
      def find(id:)
        Assistant.find(id:, client: @client)
      end

      # @param limit [Integer] optional
      def all(limit: nil)
        Assistant.all(limit:, client: @client)
      end

      # @param id [String] required
      def destroy!(id:)
        Assistant.destroy!(id:, client: @client)
      end

      # @param name [String]
      # @param model [String]
      # @param description [String, nil] optional
      # @param instructions [String,nil] optional
      # @param metadata [Hash] optional
      # @param tools [Array<Hash>] optional
      def build(name: nil, description: nil, instructions: nil, model: Chat::Model, metadata: {}, tools: [])
        Assistant.new(name:, model:, description:, instructions:, metadata:, tools:, client: @client)
      end
    end
  end
end
