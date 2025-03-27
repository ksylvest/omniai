# frozen_string_literal: true

module OmniAI
  module MCP
    # @example
    #   server = OmniAI::MCP::Server.new(tools: [...])
    #   server.run
    class Server
      PROTOCOL_VERSION = "2025-03-26"

      # @param tools [Array<OmniAI::Tool>]
      # @param logger [Logger, nil]
      def initialize(tools:, logger: nil, name: "OmniAI", version: OmniAI::VERSION)
        @tools = tools
        @logger = logger
        @name = name
        @version = version
      end

      # @param transport [OmniAI::MCP::Transport]
      def run(transport: OmniAI::MCP::Transport::Stdio.new)
        loop do
          message = transport.gets
          break if message.nil?

          @logger&.info("#{self.class}#run: message=#{message.inspect}")
          response = process(message)
          @logger&.info("#{self.class}#run: response=#{response.inspect}")

          transport.puts(response) if response
        end
      end

    private

      # @param message [String]
      #
      # @return [String, nil]
      def process(message)
        request = JRPC::Request.parse(message)

        response =
          case request.method
          when "initialize" then process_initialize(request:)
          when "ping" then process_ping(request:)
          when "tools/list" then process_tools_list(request:)
          when "tools/call" then process_tools_call(request:)
          end

        response&.generate if response&.result
      rescue JRPC::Error => e
        JSON.generate({
          jsonrpc: JRPC::VERSION,
          id: request&.id,
          error: {
            code: e.code,
            message: e.message,
          },
        })
      end

      # @param request [JRPC::Request]
      # @return [JRPC::Response]
      def process_initialize(request:)
        JRPC::Response.new(id: request.id, result: {
          protocolVersion: PROTOCOL_VERSION,
          serverInfo: {
            name: @name,
            version: @version,
          },
          capabilities: {},
        })
      end

      # @param request [JRPC::Request]
      # @return [JRPC::Response]
      def process_ping(request:)
        JRPC::Response.new(id: request.id, result: {})
      end

      # @param request [JRPC::Request]
      #
      # @raise [JRPC::Error]
      #
      # @return [JRPC::Response]
      def process_tools_list(request:)
        result = @tools.map do |tool|
          {
            name: tool.name,
            description: tool.description,
            inputSchema: tool.parameters.serialize,
          }
        end

        JRPC::Response.new(id: request.id, result:)
      end

      # @param request [JRPC::Request]
      #
      # @raise [JRPC::Error]
      #
      # @return [JRPC::Response]
      def process_tools_call(request:)
        name = request.params["name"]
        tool = @tools.find { |tool| tool.name.eql?(name) }

        result =
          begin
            tool.call(request.params["input"])
          rescue StandardError => e
            raise JRPC::Error.new(code: JRPC::Error::Code::INTERNAL_ERROR, message: e.message)
          end

        JRPC::Response.new(id: request.id, result:)
      end
    end
  end
end
