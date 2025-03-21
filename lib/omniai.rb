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
loader.inflector.inflect "http_error" => "HTTPError"
loader.inflector.inflect "ssl_error" => "SSLError"
loader.setup

# @example
#
#   OmniAI.chat(...)
#   OmniAI.transcribe(...)
#   OmniAI.speak(...)
#   OmniAI.embed(...)
module OmniAI
  class Error < StandardError; end

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
