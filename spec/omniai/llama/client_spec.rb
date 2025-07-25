# frozen_string_literal: true

RSpec.describe OmniAI::Llama::Client do
  subject(:client) { described_class.new }

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
