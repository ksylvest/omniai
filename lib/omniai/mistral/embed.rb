# frozen_string_literal: true

module OmniAI
  module Mistral
    # An Mistral embed implementation.
    #
    # Usage:
    #
    #   input = "..."
    #   response = OmniAI::Mistral::Embed.process!(input, client: client)
    #   response.embedding [0.0, ...]
    class Embed < OmniAI::Embed
      module Model
        EMBED = "mistral-embed"
      end

      DEFAULT_MODEL = Model::EMBED

    protected

      # @return [Hash]
      def payload
        { model: @model, input: arrayify(@input) }
      end

      # @return [String]
      def path
        "/#{OmniAI::Mistral::Client::VERSION}/embeddings"
      end

      # @param [Object] value
      # @return [Array]
      def arrayify(value)
        value.is_a?(Array) ? value : [value]
      end
    end
  end
end
