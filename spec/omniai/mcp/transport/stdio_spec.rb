# frozen_string_literal: true

RSpec.describe OmniAI::MCP::Transport::Stdio do
  subject(:transport) { described_class.new(stdin:, stdout:, stderr:) }

  let(:stdin) { StringIO.new }
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  describe "#puts" do
    it "puts to stdout" do
      transport.puts("Hello World")
      expect(stdout.string).to eq("Hello World\n")
    end
  end

  describe "#gets" do
    it "gets from stdin" do
      stdin.puts("Hello World")
      stdin.rewind
      expect(transport.gets).to eq("Hello World\n")
    end
  end
end
