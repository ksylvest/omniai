# frozen_string_literal: true

RSpec.describe OmniAI::Mistral::Client do
  subject(:client) { described_class.new }

  describe "#chat" do
    it "proxies" do
      allow(OmniAI::Mistral::Chat).to receive(:process!)
      client.chat("Hello!")
      expect(OmniAI::Mistral::Chat).to have_received(:process!)
    end
  end

  describe "#embed" do
    it "proxies" do
      allow(OmniAI::Mistral::Embed).to receive(:process!)
      client.embed("Hello!")
      expect(OmniAI::Mistral::Embed).to have_received(:process!)
    end
  end

  describe "#ocr" do
    it "proxies" do
      allow(OmniAI::Mistral::OCR).to receive(:process!)
      client.ocr("http://localhost/sample")
      expect(OmniAI::Mistral::OCR).to have_received(:process!)
    end
  end

  describe "#connection" do
    it { expect(client.connection).to be_a(HTTP::Client) }
  end
end
