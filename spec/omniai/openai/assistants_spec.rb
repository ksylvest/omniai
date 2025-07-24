# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Assistants do
  let(:assistants) { described_class.new(client:) }

  let(:client) { OmniAI::OpenAI::Client.new }

  describe "#build" do
    subject(:build) { assistants.build(name: "Ringo") }

    it { expect(build).to be_a(OmniAI::OpenAI::Assistant) }
    it { expect(build.name).to eql("Ringo") }
  end

  describe "#find" do
    subject(:find) { assistants.find(id: "asst-123") }

    it "proxies" do
      allow(OmniAI::OpenAI::Assistant).to receive(:find)
      find
      expect(OmniAI::OpenAI::Assistant).to have_received(:find).with(id: "asst-123", client:)
    end
  end

  describe "#all" do
    subject(:all) { assistants.all(limit: 50) }

    it "proxies" do
      allow(OmniAI::OpenAI::Assistant).to receive(:all)
      all
      expect(OmniAI::OpenAI::Assistant).to have_received(:all).with(limit: 50, client:)
    end
  end

  describe "#destroy!" do
    subject(:destroy!) { assistants.destroy!(id: "asst-123") }

    it "proxies" do
      allow(OmniAI::OpenAI::Assistant).to receive(:destroy!)
      destroy!
      expect(OmniAI::OpenAI::Assistant).to have_received(:destroy!).with(id: "asst-123", client:)
    end
  end
end
