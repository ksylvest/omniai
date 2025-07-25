# frozen_string_literal: true

module OmniAI
  module OpenAI
    # Configuration for OpenAI.
    class Config
      DEFAULT_HOST = "https://api.openai.com"

      # @!attribute [rw] api_key
      #   @return [String]
      attr_accessor :api_key

      # @!attribute [rw] host
      #   @return [String]
      attr_accessor :host

      # @!attribute [rw] organization
      #   @return [String, nil] passed as `OpenAI-Organization` if specified
      attr_accessor :organization

      # @!attribute [rw] project
      #   @return [String, nil] passed as `OpenAI-Organization` if specified
      attr_accessor :project

      def initialize
        @api_key = ENV.fetch("OPENAI_API_KEY", nil)
        @host = ENV.fetch("OPENAI_HOST", DEFAULT_HOST)
        @organization = ENV.fetch("OPENAI_ORGANIZATION", nil)
        @project = ENV.fetch("OPENAI_PROJECT", nil)
      end
    end
  end
end
