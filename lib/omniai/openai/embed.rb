# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI embed implementation.
    #
    # Usage:
    #
    #   input = "..."
    #   response = OmniAI::OpenAI::Embed.process!(input, client: client)
    #   response.embedding [0.0, ...]
    class Embed < OmniAI::Embed
      module Model
        TEXT_EMBEDDING_3_SMALL = "text-embedding-3-small"
        TEXT_EMBEDDING_3_LARGE = "text-embedding-3-large"
        TEXT_EMBEDDING_ADA_002 = "text-embedding-ada-002"
        SMALL = TEXT_EMBEDDING_3_SMALL
        LARGE = TEXT_EMBEDDING_3_LARGE
        ADA = TEXT_EMBEDDING_ADA_002
      end

      DEFAULT_MODEL = Model::LARGE

    protected

      # @return [Hash]
      def payload
        { model: @model, input: arrayify(@input) }
      end

      # @return [String]
      def path
        "#{@client.api_prefix}/#{OmniAI::OpenAI::Client::VERSION}/embeddings"
      end

      # @param [Object] value
      # @return [Array]
      def arrayify(value)
        value.is_a?(Array) ? value : [value]
      end
    end
  end
end
