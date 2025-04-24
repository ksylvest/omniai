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

module OmniAI
  class Error < StandardError; end
end
