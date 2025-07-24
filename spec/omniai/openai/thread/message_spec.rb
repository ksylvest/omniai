# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Thread::Message do
  let(:client) { OmniAI::OpenAI::Client.new }

  describe "#inspect" do
    subject(:inspect) { message.inspect }

    let(:message) do
      described_class.new(client:, id: "msg-123", thread_id: "thread-123", content: "Hello!")
    end

    it { is_expected.to eql('#<OmniAI::OpenAI::Thread::Message id="msg-123" thread_id="thread-123" content="Hello!">') }
  end

  describe ".find" do
    subject(:find) { described_class.find(thread_id: "thread-123", id: "msg-123", client:) }

    context "with an OK response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/threads/thread-123/messages/msg-123")
          .to_return_json(body: {
            id: "msg-123",
            thread_id: "thread-123",
            run_id: "run-123",
            role: "user",
            content: "Hello!",
            metadata: { user: "Ringo" },
          })
      end

      it { expect(find.id).to eql("msg-123") }
      it { expect(find.thread_id).to eql("thread-123") }
      it { expect(find.run_id).to eql("run-123") }
      it { expect(find.role).to eql("user") }
      it { expect(find.content).to eql("Hello!") }
      it { expect(find.metadata).to eql("user" => "Ringo") }
    end

    context "with a MISSING response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/threads/thread-123/messages/msg-123")
          .to_return_json(status: 404)
      end

      it { expect { find }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe ".all" do
    subject(:all) { described_class.all(thread_id: "thread-123", client:) }

    context "with an OK response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/threads/thread-123/messages")
          .to_return_json(body: {
            data: [
              {
                id: "msg-123",
                thread_id: "thread-123",
                run_id: "run-123",
                role: "user",
                content: "Hello!",
                metadata: { user: "Ringo" },
              },
            ],
          })
      end

      it { expect(all).to be_an(Array) }
    end

    context "with a UNPROCESSABLE response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/threads/thread-123/messages")
          .to_return(status: 422)
      end

      it { expect { all }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe ".destroy!" do
    subject(:destroy!) { described_class.destroy!(thread_id: "thread-123", id: "msg-123", client:) }

    context "with an OK response" do
      before do
        stub_request(:delete, "https://api.openai.com/v1/threads/thread-123/messages/msg-123")
          .to_return_json(body: {
            id: "msg-123",
            deleted: true,
          })
      end

      it { expect(destroy!["id"]).to eql("msg-123") }
      it { expect(destroy!["deleted"]).to be_truthy }
    end

    context "with a MISSING response" do
      before do
        stub_request(:delete, "https://api.openai.com/v1/threads/thread-123/messages/msg-123")
          .to_return_json(status: 404)
      end

      it { expect { destroy! }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe "#destroy!" do
    subject(:destroy!) { assistant.destroy! }

    let(:assistant) { described_class.new(client:, id: "msg-123", thread_id: "thread-123") }

    context "with an OK response" do
      before do
        stub_request(:delete, "https://api.openai.com/v1/threads/thread-123/messages/msg-123")
          .to_return_json(body: {
            id: "msg-123",
            deleted: true,
          })
      end

      it { expect { destroy! }.to change(assistant, :deleted).from(nil).to(true) }
    end

    context "with a MISSING response" do
      before do
        stub_request(:delete, "https://api.openai.com/v1/threads/thread-123/messages/msg-123")
          .to_return_json(status: 404)
      end

      it { expect { destroy! }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe "#save!" do
    subject(:save!) { message.save! }

    context "when creating a message" do
      let(:message) { described_class.new(client:, thread_id: "thread-123", content: "Hello!") }

      context "with an OK response" do
        before do
          stub_request(:post, "https://api.openai.com/v1/threads/thread-123/messages")
            .to_return_json(body: {
              id: "msg-123",
              thread_id: "thread-123",
              run_id: "run-123",
              role: "user",
              content: "Hello!",
              metadata: { user: "Ringo" },
            })
        end

        it { expect(save!.id).to eql("msg-123") }
        it { expect(save!.thread_id).to eql("thread-123") }
        it { expect(save!.run_id).to eql("run-123") }
        it { expect(save!.role).to eql("user") }
        it { expect(save!.content).to eql("Hello!") }
        it { expect(save!.metadata).to eql("user" => "Ringo") }
      end

      context "with an UNPROCESSABLE response" do
        before do
          stub_request(:post, "https://api.openai.com/v1/threads/thread-123/messages")
            .to_return(status: 422)
        end

        it { expect { save! }.to raise_error(OmniAI::HTTPError) }
      end
    end

    context "when updating a message" do
      let(:message) { described_class.new(client:, id: "msg-123", thread_id: "thread-123", content: "Hello!") }

      context "with an OK response" do
        before do
          stub_request(:post, "https://api.openai.com/v1/threads/thread-123/messages/msg-123")
            .to_return_json(body: {
              id: "msg-123",
              thread_id: "thread-123",
              run_id: "run-123",
              role: "user",
              content: "Hello!",
              metadata: { user: "Ringo" },
            })
        end

        it { expect(save!.id).to eql("msg-123") }
        it { expect(save!.thread_id).to eql("thread-123") }
        it { expect(save!.run_id).to eql("run-123") }
        it { expect(save!.role).to eql("user") }
        it { expect(save!.content).to eql("Hello!") }
        it { expect(save!.metadata).to eql("user" => "Ringo") }
      end

      context "with an UNPROCESSABLE response" do
        before do
          stub_request(:post, "https://api.openai.com/v1/threads/thread-123/messages/msg-123")
            .to_return(status: 422)
        end

        it { expect { save! }.to raise_error(OmniAI::HTTPError) }
      end
    end
  end
end
