# frozen_string_literal: true

module OmniAI
  module Llama
    # Configuration for Llama.
    class Config
      DEFAULT_HOST = "https://api.llama.com"

      # @!attribute [rw] api_key
      #   @return [String]
      attr_accessor :api_key

      # @!attribute [rw] host
      #   @return [String]
      attr_accessor :host

      def initialize
        @api_key = ENV.fetch("LLAMA_API_KEY", nil)
        @host = ENV.fetch("LLAMA_HOST", DEFAULT_HOST)
      end
    end
  end
end
