# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Thread::Runs do
  subject(:runs) { described_class.new(client:, thread:) }

  let(:thread) { instance_double(OmniAI::OpenAI::Thread, id: "thread-123") }
  let(:client) { OmniAI::OpenAI::Client.new }

  describe "#build" do
    subject(:build) { runs.build(assistant_id: "asssitant-123") }

    it { expect(build).to be_a(OmniAI::OpenAI::Thread::Run) }
  end

  describe "#find" do
    subject(:find) { runs.find(id: "run-123") }

    it "proxies" do
      allow(OmniAI::OpenAI::Thread::Run).to receive(:find)
      find
      expect(OmniAI::OpenAI::Thread::Run).to have_received(:find)
        .with(thread_id: "thread-123", id: "run-123", client:)
    end
  end

  describe "#all" do
    subject(:all) { runs.all(limit: 50) }

    it "proxies" do
      allow(OmniAI::OpenAI::Thread::Run).to receive(:all)
      all
      expect(OmniAI::OpenAI::Thread::Run).to have_received(:all)
        .with(thread_id: "thread-123", limit: 50, client:)
    end
  end

  describe "#cancel!" do
    subject(:cancel!) { runs.cancel!(id: "run-123") }

    it "proxies" do
      allow(OmniAI::OpenAI::Thread::Run).to receive(:cancel!)
      cancel!
      expect(OmniAI::OpenAI::Thread::Run).to have_received(:cancel!)
        .with(thread_id: "thread-123", id: "run-123", client:)
    end
  end
end
