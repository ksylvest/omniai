# frozen_string_literal: true

RSpec.describe OmniAI::Llama::Client do
  subject(:client) { described_class.new }

  describe "#initialize" do
    context "with an api_key" do
      it { expect(described_class.new(api_key: "...")).to be_a(described_class) }
    end

    context "without an api_key" do
      it { expect { described_class.new(api_key: nil) }.to raise_error(ArgumentError) }
    end
  end

  describe "#connection" do
    it { expect(client.connection).to be_a(HTTP::Client) }
  end

  describe "#chat" do
    it "proxies" do
      allow(OmniAI::Llama::Chat).to receive(:process!)
      client.chat("Hello!")
      expect(OmniAI::Llama::Chat).to have_received(:process!)
    end
  end
end
