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
end
