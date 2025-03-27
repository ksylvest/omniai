# frozen_string_literal: true

module OmniAI
  module MCP
    module JRPC
      # @example
      #   request = OmniAI::MCP::JRPC::Request.new(id: 0, method: "ping", params: {})
      #   request.id #=> 0
      #   request.method #=> "ping"
      #   request.params #=> {}
      class Request
        # @!attribute [rw] id
        #   @return [Integer]
        attr_accessor :id

        # @!attribute [rw] method
        #   @return [String]
        attr_accessor :method

        # @!attribute [rw] params
        #   @return [Hash]
        attr_accessor :params

        # @param id [Integer]
        # @param method [String]
        # @param params [Hash]
        def initialize(id:, method:, params:)
          @id = id
          @method = method
          @params = params
        end

        # @return [String]
        def inspect
          "#<#{self.class.name} id=#{@id} method=#{@method} params=#{@params}>"
        end

        # @return [String]
        def generate
          JSON.generate({
            jsonrpc: VERSION,
            id: @id,
            method: @method,
            params: @params,
          })
        end

        # @param text [String]
        #
        # @raise [OmniAI::MCP::JRPC::Error]
        #
        # @return [OmniAI::MCP::JRPC::Request]
        def self.parse(text)
          data =
            begin
              JSON.parse(text)
            rescue JSON::ParserError => e
              raise Error.new(code: Error::Code::PARSE_ERROR, message: e.message)
            end

          id = data["id"] || raise(Error.new(code: Error::Code::PARSE_ERROR, message: "missing id"))
          method = data["method"] || raise(Error.new(code: Error::Code::PARSE_ERROR, message: "missing method"))
          params = data["params"] || raise(Error.new(code: Error::Code::PARSE_ERROR, message: "missing params"))

          new(id:, method:, params:)
        end
      end
    end
  end
end
