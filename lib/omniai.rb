# frozen_string_literal: true

require 'http'

require_relative 'omniai/version'
require_relative 'omniai/client'
require_relative 'omniai/chat'
require_relative 'omniai/chat/completion'

module OmniAI
  class Error < StandardError; end

  # An error that wraps an HTTP::Response for non-OK requests.
  class HTTPError < Error
    attr_accessor :response

    # @param response [HTTP::Response]
    def initialize(response)
      super("status=#{response.status} headers=#{response.headers} body=#{response.body}")
      @response = response
    end
  end
end
