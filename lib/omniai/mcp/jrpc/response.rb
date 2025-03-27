# frozen_string_literal: true

module OmniAI
  module MCP
    module JRPC
      # @example
      #   request = OmniAI::MCP::JRPC::Response.new(id: 0, result: "OK")
      #   request.generate #=> { "jsonrpc": "2.0", "id": 0, "result": "OK" }
      class Response
        # @!attribute [rw] id
        #   @return [Integer]
        attr_accessor :id

        # @!attribute [rw] result
        #   @return [String]
        attr_accessor :result

        # @param id [Integer]
        # @param result [String]
        def initialize(id:, result:)
          @id = id
          @result = result
        end

        # @return [String]
        def inspect
          "#<#{self.class.name} id=#{@id} result=#{@result}>"
        end

        # @return [String]
        def generate
          JSON.generate({
            jsonrpc: VERSION,
            id: @id,
            result: @result,
          })
        end

        # @param text [String]
        #
        # @raise [OmniAI::MCP::JRPC::Error]
        #
        # @return [OmniAI::MCP::JRPC::Response]
        def self.parse(text)
          data =
            begin
              JSON.parse(text)
            rescue JSON::ParserError => e
              raise Error.new(code: Error::Code::PARSE_ERROR, message: e.message)
            end

          id = data["id"] || raise(Error.new(code: Error::Code::PARSE_ERROR, message: "missing id"))
          result = data["result"] || raise(Error.new(code: Error::Code::PARSE_ERROR, message: "missing result"))

          new(id:, result:)
        end
      end
    end
  end
end
