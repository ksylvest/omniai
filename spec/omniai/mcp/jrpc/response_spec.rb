# frozen_string_literal: true

RSpec.describe OmniAI::MCP::JRPC::Response do
  describe ".parse" do
    subject(:parse) { described_class.parse(text) }

    context "with valid JSON" do
      let(:text) { '{"jsonrpc":"2.0","id":0,"result":"OK"}' }

      it "parses" do
        expect(parse).to be_a(described_class)
        expect(parse.id).to be(0)
        expect(parse.result).to eql("OK")
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

    let(:request) { described_class.new(id: 0, result: "OK") }

    it "generates" do
      expect(generate).to eql('{"jsonrpc":"2.0","id":0,"result":"OK"}')
    end
  end

  describe "#inspect" do
    subject(:inspect) { request.inspect }

    let(:request) { described_class.new(id: 0, result: "OK") }

    it "inspects" do
      expect(inspect).to eql("#<OmniAI::MCP::JRPC::Response id=0 result=OK>")
    end
  end
end
