# frozen_string_literal: true

module OmniAI
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
