# frozen_string_literal: true

module OmniAI
  module OpenAI
    # Configuration for OpenAI.
    class Config
      DEFAULT_HOST = "https://api.openai.com"
      DEFAULT_VERSION = "v1"

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
        @version = ENV.fetch("OPENAI_VERSION", DEFAULT_VERSION)
        @organization = ENV.fetch("OPENAI_ORGANIZATION", nil)
        @project = ENV.fetch("OPENAI_PROJECT", nil)
      end

      # @return [String]
      def base_url
        "#{@host}/#{@version}"
      end
    end
  end
end
