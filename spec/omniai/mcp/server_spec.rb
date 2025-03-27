# frozen_string_literal: true

RSpec.describe OmniAI::MCP::Server do
  subject(:server) { described_class.new(tools: [tool]) }

  let(:tool) { build(:tool) }
  let(:transport) { OmniAI::MCP::Transport::Stdio.new(stdin:, stdout:, stderr:) }
  let(:stdin) { StringIO.new }
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  describe "#run" do
    subject(:run) do
      stdin << input
      stdin.rewind
      server.run(transport:)
      stdout.string
    end

    context "when processing initialize" do
      let(:input) do
        <<~JSON
          #{JSON.generate(jsonrpc: '2.0', id: 0, method: 'initialize', params: {})}
        JSON
      end

      let(:output) do
        <<~JSON
          #{JSON.generate(jsonrpc: '2.0', id: 0, result: {
            protocolVersion: described_class::PROTOCOL_VERSION,
            serverInfo: {
              name: 'OmniAI',
              version: OmniAI::VERSION,
            },
            capabilities: {},
          })}
        JSON
      end

      it "returns a response" do
        expect(run).to eql(output)
      end
    end

    context "when processing ping" do
      let(:input) do
        <<~JSON
          #{JSON.generate(jsonrpc: '2.0', id: 0, method: 'ping', params: {})}
        JSON
      end

      let(:output) do
        <<~JSON
          #{JSON.generate(jsonrpc: '2.0', id: 0, result: {})}
        JSON
      end

      it "returns a response" do
        expect(run).to eql(output)
      end
    end

    context "when processing tools/list" do
      let(:input) do
        <<~JSON
          #{JSON.generate(jsonrpc: '2.0', id: 0, method: 'tools/list', params: {})}
        JSON
      end

      let(:output) do
        <<~JSON
          #{JSON.generate(jsonrpc: '2.0', id: 0, result: [
            {
              name: 'weather',
              description: 'Finds the weather for a location.',
              inputSchema: {
                type: 'object',
                properties: { location: { type: 'string' } },
                required: ['location'],
              },
            },
          ])}
        JSON
      end

      it "returns a response" do
        expect(run).to eql(output)
      end
    end

    context "when processing tools/call for weather in london" do
      let(:input) do
        <<~JSON
          #{JSON.generate(jsonrpc: '2.0', id: 0, method: 'tools/call', params: {
            name: 'weather',
            input: { location: 'London' },
          })}
        JSON
      end

      let(:output) do
        <<~JSON
          #{JSON.generate(jsonrpc: '2.0', id: 0, result: 'Rainy')}
        JSON
      end

      it "returns a response" do
        expect(run).to eql(output)
      end
    end

    context "when processing tools/call for weather in madrid" do
      let(:input) do
        <<~JSON
          #{JSON.generate(jsonrpc: '2.0', id: 0, method: 'tools/call', params: {
            name: 'weather',
            input: { location: 'Madrid' },
          })}
        JSON
      end

      let(:output) do
        <<~JSON
          #{JSON.generate(jsonrpc: '2.0', id: 0, result: 'Sunny')}
        JSON
      end

      it "returns a response" do
        expect(run).to eql(output)
      end
    end

    context "when processing tools/call for weather in toronto" do
      let(:input) do
        <<~JSON
          #{JSON.generate(jsonrpc: '2.0', id: 0, method: 'tools/call', params: {
            name: 'weather',
            input: { location: 'Toronto' },
          })}
        JSON
      end

      let(:output) do
        <<~JSON
          #{JSON.generate(jsonrpc: '2.0', id: 0, error: {
            code: OmniAI::MCP::JRPC::Error::Code::INTERNAL_ERROR,
            message: 'unknown location=Toronto',
          })}
        JSON
      end

      it "returns a response" do
        expect(run).to eql(output)
      end
    end
  end
end
