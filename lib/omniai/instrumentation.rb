# frozen_string_literal: true

module OmniAI
  # Used for logging.
  class Instrumentation
    # @param logger [Logger]
    def initialize(logger:)
      @logger = logger
    end

    # ActiveSupport::Notifications-compatible instrument.
    #
    # On http 6 the instrumentation feature drives every request through
    # `around_request`, which (per http's own feature docs) "emits two events on
    # every request: `start_request.http` before the request is made [and]
    # `request.http` after the response is received". Both are delivered here as
    # `instrument(name) { ... }` calls: the start event carries an empty block,
    # and the request event's block wraps the exchange and returns the response.
    # The block of the request event MUST be yielded and its value returned,
    # otherwise the response is lost as `nil` (http uses the return value as the
    # response). We log the request on the start event and the response on the
    # request event. The event namespace is caller-configurable (the names are
    # `start_request.#{namespace}` / `request.#{namespace}`), so #start_event?
    # prefix-matches rather than comparing the full name.
    #
    # On http 5 this is only ever called without a block (for the start and
    # error events); request/response logging there happens via #start / #finish.
    #
    # @param name [String]
    # @param payload [Hash]
    # @option payload [HTTP::Request] :request
    # @option payload [HTTP::Response] :response
    # @option payload [Exception] :error
    def instrument(name, payload = {})
      error = payload[:error]
      @logger.error("#{name}: #{error.message}") if error

      return unless block_given?

      if start_event?(name)
        log_request(payload[:request])
        yield payload
      else
        response = yield payload
        log_response(payload[:response] || response)
        response
      end
    end

    # @param payload [Hash]
    # @option payload [HTTP::Request] :request
    def start(_, payload)
      log_request(payload[:request])
    end

    # @param payload [Hash]
    # @option payload [HTTP::Response] :response
    def finish(_, payload)
      log_response(payload[:response])
    end

  private

    # @param name [String] the http instrumentation event name, e.g.
    #   "start_request.http" (pre-flight) or "request.http" (the exchange).
    #
    # @return [Boolean] true for the pre-flight "start_..." event
    def start_event?(name)
      name.to_s.start_with?("start_")
    end

    # @param request [HTTP::Request, nil]
    def log_request(request)
      return unless request

      @logger.info("#{request.verb.upcase} #{request.uri}")
    end

    # @param response [HTTP::Response, nil]
    def log_response(response)
      return unless response

      @logger.info("#{response.status.code} #{response.status.reason}")
    end
  end
end
