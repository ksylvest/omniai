# frozen_string_literal: true

require "logger"
require "event_stream_parser"
require "http"
require "uri"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect "omniai" => "OmniAI"
loader.inflector.inflect "cli" => "CLI"
loader.inflector.inflect "jrpc" => "JRPC"
loader.inflector.inflect "mcp" => "MCP"
loader.inflector.inflect "url" => "URL"
loader.setup

# @example
#
#   OmniAI.chat(...)
#   OmniAI.transcribe(...)
#   OmniAI.speak(...)
#   OmniAI.embed(...)
module OmniAI
  class Error < StandardError; end

  # An error that wraps an HTTP::Response for non-OK requests.
  class HTTPError < Error
    # @!attribute [rw] response
    #   @return [HTTP::Response]
    attr_accessor :response

    # @param response [HTTP::Response]
    def initialize(response)
      super("status=#{response.status} body=#{response.body}")

      @response = response
    end

    # @return [String]
    def inspect
      "#<#{self.class} status=#{@response.status} body=#{@response.body}>"
    end
  end

  # @see OmniAI::Client#chat
  def self.chat(...)
    OmniAI::Client.discover.chat(...)
  end

  # @see OmniAI::Client#transcribe
  def self.transcribe(...)
    OmniAI::Client.discover.transcribe(...)
  end

  # @see OmniAI::Client#speak
  def self.speak(...)
    OmniAI::Client.discover.speak(...)
  end

  # @see OmniAI::Client#embed
  def self.embed(...)
    OmniAI::Client.discover.embed(...)
  end
end
