# frozen_string_literal: true

RSpec.describe OmniAI::DeepSeek::Client do
  subject(:client) { described_class.new }

  describe "#chat" do
    it "proxies" do
      allow(OmniAI::DeepSeek::Chat).to receive(:process!)
      client.chat("Hello!")
      expect(OmniAI::DeepSeek::Chat).to have_received(:process!)
    end
  end
end
