# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Thread::Messages do
  subject(:messages) { described_class.new(client:, thread:) }

  let(:thread) { instance_double(OmniAI::OpenAI::Thread, id: "thread-123") }
  let(:client) { OmniAI::OpenAI::Client.new }

  describe "#build" do
    subject(:build) { messages.build(role: "user", content: "Hello?") }

    it { expect(build).to be_a(OmniAI::OpenAI::Thread::Message) }
    it { expect(build.role).to eql("user") }
    it { expect(build.content).to eql("Hello?") }
  end

  describe "#find" do
    subject(:find) { messages.find(id: "msg-123") }

    it "proxies" do
      allow(OmniAI::OpenAI::Thread::Message).to receive(:find)
      find
      expect(OmniAI::OpenAI::Thread::Message).to have_received(:find)
        .with(thread_id: "thread-123", id: "msg-123", client:)
    end
  end

  describe "#all" do
    subject(:all) { messages.all(limit: 50) }

    it "proxies" do
      allow(OmniAI::OpenAI::Thread::Message).to receive(:all)
      all
      expect(OmniAI::OpenAI::Thread::Message).to have_received(:all)
        .with(thread_id: "thread-123", limit: 50, client:)
    end
  end

  describe "#destroy!" do
    subject(:destroy!) { messages.destroy!(id: "msg-123") }

    it "proxies" do
      allow(OmniAI::OpenAI::Thread::Message).to receive(:destroy!)
      destroy!
      expect(OmniAI::OpenAI::Thread::Message).to have_received(:destroy!)
        .with(thread_id: "thread-123", id: "msg-123", client:)
    end
  end
end
