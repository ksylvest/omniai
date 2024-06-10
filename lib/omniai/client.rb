# frozen_string_literal: true

# Usage:
#
#   require "omniai"
#   require "omniai-anthropic"
#   require "omniai-google"
#   require "omniai-mistral"
#   require "omniai-openai"
#
#   anthropic = OmniAI::Anthropic.new(api_key: ENV.fetch("OPENAI_API_KEY"))
#   google = OmniAI::Google.new(api_key: ENV.fetch("OPENAI_API_KEY"))
#   mistral = OmniAI::Mistral.new(api_key: ENV.fetch("OPENAI_API_KEY"))
#   openai = OmniAI::OpenAI.new(api_key: ENV.fetch("OPENAI_API_KEY"))

module OmniAI::Client
  class Error < StandardError; end

  # @param api_key [String] The API key to use for requests
  def initialize(api_key:)
    @api_key = api_key
  end

  def http
    HTTP.auth("Bearer #{@api_key}")
  end
end
