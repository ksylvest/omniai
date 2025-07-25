# frozen_string_literal: true

module OmniAI
  module Mistral
    # Configuration for Mistral.
    class Config
      DEFAULT_HOST = "https://api.mistral.ai"

      # @!attribute [rw] api_key
      #   @return [String]
      attr_accessor :api_key

      # @!attribute [rw] host
      #   @return [String]
      attr_accessor :host

      def initialize
        @api_key = ENV.fetch("MISTRAL_API_KEY", nil)
        @host = ENV.fetch("MISTRAL_HOST", DEFAULT_HOST)
      end
    end
  end
end
