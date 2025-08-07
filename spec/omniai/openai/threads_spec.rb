# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Threads do
  let(:threads) { described_class.new(client:) }

  let(:client) { OmniAI::OpenAI::Client.new }

  describe "#build" do
    subject(:build) { threads.build }

    it { expect(build).to be_a(OmniAI::OpenAI::Thread) }
  end

  describe "#find" do
    subject(:find) { threads.find(id: "thread-123") }

    it "proxies" do
      allow(OmniAI::OpenAI::Thread).to receive(:find)
      find
      expect(OmniAI::OpenAI::Thread).to have_received(:find).with(id: "thread-123", client:)
    end
  end

  describe "#destroy!" do
    subject(:destroy!) { threads.destroy!(id: "thread-123") }

    it "proxies" do
      allow(OmniAI::OpenAI::Thread).to receive(:destroy!)
      destroy!
      expect(OmniAI::OpenAI::Thread).to have_received(:destroy!).with(id: "thread-123", client:)
    end
  end
end
