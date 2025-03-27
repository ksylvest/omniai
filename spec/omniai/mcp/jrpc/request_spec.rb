# frozen_string_literal: true

RSpec.describe OmniAI::MCP::JRPC::Request do
  describe ".parse" do
    subject(:parse) { described_class.parse(text) }

    let(:text) { '{"jsonrpc":"2.0","id":0,"method":"ping","params":{}}' }

    context "with valid JSON" do
      it "parses" do
        expect(parse).to be_a(described_class)
        expect(parse.id).to be(0)
        expect(parse.method).to eql("ping")
        expect(parse.params).to eql({})
      end
    end

    context "with invalid JSON" do
      let(:text) { "}{" }

      it "raises an error" do
        expect { parse }.to raise_error(OmniAI::MCP::JRPC::Error)
      end
    end
  end

  describe "#generate" do
    subject(:generate) { request.generate }

    let(:request) { described_class.new(id: 0, method: "ping", params: {}) }

    it "generates" do
      expect(generate).to eql('{"jsonrpc":"2.0","id":0,"method":"ping","params":{}}')
    end
  end

  describe "#inspect" do
    subject(:inspect) { request.inspect }

    let(:request) { described_class.new(id: 0, method: "ping", params: {}) }

    it "inspects" do
      expect(inspect).to eql("#<OmniAI::MCP::JRPC::Request id=0 method=ping params={}>")
    end
  end
end
