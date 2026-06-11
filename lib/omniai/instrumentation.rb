# frozen_string_literal: true

module OmniAI
  # Used for logging.
  class Instrumentation
    # @param logger [Logger]
    def initialize(logger:)
      @logger = logger
    end

    # ActiveSupport::Notifications-compatible instrument. On http 6 the
    # instrumentation feature drives the whole request through `around_request`
    # → `instrument(name, ...) { ... }` and uses the block's return value as the
    # response, so the block MUST be yielded and its result returned (otherwise
    # the response is lost as `nil`). On http 5 this is only ever called without
    # a block for the start/error events (logging is done via #start / #finish).
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

      if name.to_s.start_with?("start_")
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
