# frozen_string_literal: true

module OmniAI
  module Google
    # An Google embed implementation.
    #
    # Usage:
    #
    #   input = "..."
    #   response = OmniAI::Google::Embed.process!(input, client: client)
    #   response.embedding [0.0, ...]
    class Embed < OmniAI::Embed
      module Model
        TEXT_EMBEDDING_004 = "text-embedding-004"
        TEXT_EMBEDDING_005 = "text-embedding-005"
        TEXT_MULTILINGUAL_EMBEDDING_002 = "text-multilingual-embedding-002"
        EMBEDDING = TEXT_EMBEDDING_004
        MULTILINGUAL_EMBEDDING = TEXT_MULTILINGUAL_EMBEDDING_002
      end

      DEFAULT_MODEL = Model::EMBEDDING

      DEFAULT_EMBEDDINGS_DESERIALIZER = proc do |data, *|
        data["embeddings"].map { |embedding| embedding["values"] }
      end

      VERTEX_EMBEDDINGS_DESERIALIZER = proc do |data, *|
        data["predictions"].map { |prediction| prediction["embeddings"]["values"] }
      end

      VERTEX_USAGE_DESERIALIZER = proc do |data, *|
        tokens = data["predictions"].map { |prediction| prediction["embeddings"]["statistics"]["token_count"] }.sum

        Usage.new(prompt_tokens: tokens, total_tokens: tokens)
      end

      # @return [Context]
      DEFAULT_CONTEXT = Context.build do |context|
        context.deserializers[:embeddings] = DEFAULT_EMBEDDINGS_DESERIALIZER
      end

      # @return [Context]
      VERTEX_CONTEXT = Context.build do |context|
        context.deserializers[:embeddings] = VERTEX_EMBEDDINGS_DESERIALIZER
        context.deserializers[:usage] = VERTEX_USAGE_DESERIALIZER
      end

    protected

      # @return [Boolean]
      def vertex?
        @client.vertex?
      end

      # @return [Context]
      def context
        vertex? ? VERTEX_CONTEXT : DEFAULT_CONTEXT
      end

      # @return [Array[Hash]]
      def instances
        arrayify(@input).map { |content| { content: } }
      end

      # @return [Array[Hash]]
      def requests
        arrayify(@input).map do |text|
          {
            model: "models/#{@model}",
            content: { parts: [{ text: }] },
          }
        end
      end

      # @return [Hash]
      def payload
        vertex? ? { instances: } : { requests: }
      end

      # @return [Hash]
      def params
        { key: (@client.api_key unless @client.credentials?) }.compact
      end

      # @return [String]
      def path
        "/#{@client.path}/models/#{@model}:#{procedure}"
      end

      # @return [String]
      def procedure
        vertex? ? "predict" : "batchEmbedContents"
      end

      # @param input [Object]
      # @return [Array]
      def arrayify(input)
        input.is_a?(Array) ? input : [input]
      end
    end
  end
end
