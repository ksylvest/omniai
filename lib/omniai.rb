# frozen_string_literal: true

require 'logger'
require 'event_stream_parser'
require 'http'
require 'uri'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect 'omniai' => 'OmniAI'
loader.inflector.inflect 'url' => 'URL'
loader.inflector.inflect 'cli' => 'CLI'
loader.setup

module OmniAI
  class Error < StandardError; end

  # An error that wraps an HTTP::Response for non-OK requests.
  class HTTPError < Error
    # @return [HTTP::Response]
    attr_accessor :response

    # @param response [HTTP::Response]
    def initialize(response)
      super("status=#{response.status} body=#{response.body}")

      @response = response
    end

    def inspect
      "#<#{self.class} status=#{@response.status} body=#{@response.body}>"
    end
  end
end
