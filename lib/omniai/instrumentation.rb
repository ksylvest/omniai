# frozen_string_literal: true

module OmniAI
  # Used for logging.
  class Instrumentation
    # @param logger [Logger]
    def initialize(logger:)
      @logger = logger
    end

    # @param name [String]
    # @param payload [Hash]
    # @option payload [Exception] :error
    def instrument(name, payload = {})
      error = payload[:error]
      return unless error

      @logger.error("#{name}: #{error.message}")
    end

    # @param name [String]
    # @param payload [Hash]
    # @option payload [HTTP::Request] :request
    def start(_, payload)
      request = payload[:request]
      @logger.info("#{request.verb.upcase} #{request.uri}")
    end

    # @param name [String]
    # @param payload [Hash]
    # @option payload [HTTP::Response] :response
    def finish(_, payload)
      response = payload[:response]
      @logger.info("#{response.status.code} #{response.status.reason}")
    end
  end
end
