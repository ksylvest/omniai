# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Files do
  let(:files) { described_class.new(client:) }

  let(:client) { OmniAI::OpenAI::Client.new }

  describe "#build" do
    subject(:build) { files.build }

    it { expect(build).to be_a(OmniAI::OpenAI::File) }
  end

  describe "#find" do
    subject(:find) { files.find(id: "file-123") }

    it "proxies" do
      allow(OmniAI::OpenAI::File).to receive(:find)
      find
      expect(OmniAI::OpenAI::File).to have_received(:find).with(id: "file-123", client:)
    end
  end

  describe "#all" do
    subject(:all) { files.all }

    it "proxies" do
      allow(OmniAI::OpenAI::File).to receive(:all)
      all
      expect(OmniAI::OpenAI::File).to have_received(:all).with(client:)
    end
  end

  describe "#destroy!" do
    subject(:destroy!) { files.destroy!(id: "file-123") }

    it "proxies" do
      allow(OmniAI::OpenAI::File).to receive(:destroy!)
      destroy!
      expect(OmniAI::OpenAI::File).to have_received(:destroy!).with(id: "file-123", client:)
    end
  end
end
