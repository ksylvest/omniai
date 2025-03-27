# frozen_string_literal: true

module OmniAI
  module MCP
    module JRPC
      # @example
      #   raise OmniAI::MCP::JRPC::Error.new(code: OmniAI::MCP::JRPC::Error::PARSE_ERROR, message: "Invalid JSON")
      class Error < StandardError
        module Code
          PARSE_ERROR = -32_700
          INVALID_REQUEST = -32_600
          METHOD_NOT_FOUND = -32_601
          INVALID_PARAMS = -32_602
          INTERNAL_ERROR = -32_603
        end

        # @!attribute [r] code
        #   @return [Integer]
        attr_accessor :code

        # @!attribute [r] message
        #   @return [String]
        attr_accessor :message

        # @param code [Integer]
        # @param message [String]
        def initialize(code:, message:)
          super("code=#{code} message=#{message}")

          @code = code
          @message = message
        end
      end
    end
  end
end
