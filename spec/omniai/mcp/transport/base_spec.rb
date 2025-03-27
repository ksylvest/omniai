# frozen_string_literal: true

RSpec.describe OmniAI::MCP::Transport::Base do
  subject(:transport) { described_class.new }

  describe "#puts" do
    it "raises NotImplementedError" do
      expect { transport.puts("Hello World") }.to raise_error(NotImplementedError)
    end
  end

  describe "#gets" do
    it "raises NotImplementedError" do
      expect { transport.gets }.to raise_error(NotImplementedError)
    end
  end
end
