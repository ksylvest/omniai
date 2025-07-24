# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Thread do
  let(:client) { OmniAI::OpenAI::Client.new }

  describe "#inspect" do
    subject(:inspect) { thread.inspect }

    let(:thread) { described_class.new(client:, id: "thread-123") }

    it { is_expected.to eql('#<OmniAI::OpenAI::Thread id="thread-123">') }
  end

  describe ".find" do
    subject(:find) { described_class.find(id: "thread-123", client:) }

    context "with an OK response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/threads/thread-123")
          .to_return_json(body: {
            id: "thread-123",
            metadata: { user: "Ringo" },
          })
      end

      it { expect(find.id).to eql("thread-123") }
      it { expect(find.metadata).to eql("user" => "Ringo") }
    end

    context "with a MISSING response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/threads/thread-123")
          .to_return_json(status: 404)
      end

      it { expect { find }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe ".destroy!" do
    subject(:destroy!) { described_class.destroy!(id: "thread-123", client:) }

    context "with an OK response" do
      before do
        stub_request(:delete, "https://api.openai.com/v1/threads/thread-123")
          .to_return_json(body: {
            id: "thread-123",
            deleted: true,
          })
      end

      it { expect(destroy!["id"]).to eql("thread-123") }
      it { expect(destroy!["deleted"]).to be_truthy }
    end

    context "with a MISSING response" do
      before do
        stub_request(:delete, "https://api.openai.com/v1/threads/thread-123")
          .to_return_json(status: 404)
      end

      it { expect { destroy! }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe "#destroy!" do
    subject(:destroy!) { thread.destroy! }

    let(:thread) { described_class.new(client:, id: "thread-123") }

    context "with an OK response" do
      before do
        stub_request(:delete, "https://api.openai.com/v1/threads/thread-123")
          .to_return_json(body: {
            id: "thread-123",
            deleted: true,
          })
      end

      it { expect { destroy! }.to change(thread, :deleted).from(nil).to(true) }
    end

    context "with a MISSING response" do
      before do
        stub_request(:delete, "https://api.openai.com/v1/threads/thread-123")
          .to_return_json(status: 404)
      end

      it { expect { destroy! }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe "#save!" do
    subject(:save!) { thread.save! }

    context "when creating a thread" do
      let(:thread) { described_class.new(client:, metadata: { user: "Ringo" }) }

      context "with an OK response" do
        before do
          stub_request(:post, "https://api.openai.com/v1/threads")
            .to_return_json(body: {
              id: "thread-123",
              metadata: { user: "Ringo" },
            })
        end

        it { expect(save!.id).to eql("thread-123") }
        it { expect(save!.metadata).to eql("user" => "Ringo") }
      end

      context "with an UNPROCESSABLE response" do
        before do
          stub_request(:post, "https://api.openai.com/v1/threads")
            .to_return(status: 422)
        end

        it { expect { save! }.to raise_error(OmniAI::HTTPError) }
      end
    end

    context "when updating an assistant" do
      let(:thread) { described_class.new(client:, id: "thread-123", metadata: { user: "Ringo" }) }

      context "with an OK response" do
        before do
          stub_request(:post, "https://api.openai.com/v1/threads/thread-123")
            .to_return_json(body: {
              id: "thread-123",
              metadata: { user: "Ringo" },
            })
        end

        it { expect(save!.id).to eql("thread-123") }
        it { expect(save!.metadata).to eql("user" => "Ringo") }
      end

      context "with an UNPROCESSABLE response" do
        before do
          stub_request(:post, "https://api.openai.com/v1/threads/thread-123")
            .to_return(status: 422)
        end

        it { expect { save! }.to raise_error(OmniAI::HTTPError) }
      end
    end
  end

  describe "#messages" do
    subject(:messages) { thread.messages }

    let(:thread) { described_class.new(client:) }

    it "proxies" do
      allow(OmniAI::OpenAI::Thread::Messages).to receive(:new)
      messages
      expect(OmniAI::OpenAI::Thread::Messages).to have_received(:new).with(thread:, client:)
    end
  end

  describe "#runs" do
    subject(:runs) { thread.runs }

    let(:thread) { described_class.new(client:) }

    it "proxies" do
      allow(OmniAI::OpenAI::Thread::Runs).to receive(:new)
      runs
      expect(OmniAI::OpenAI::Thread::Runs).to have_received(:new).with(thread:, client:)
    end
  end
end
