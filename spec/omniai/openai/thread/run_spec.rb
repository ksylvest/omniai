# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Thread::Run do
  let(:client) { OmniAI::OpenAI::Client.new }

  describe "#inspect" do
    subject(:inspect) { run.inspect }

    let(:run) { described_class.new(client:, id: "run-123") }

    it { expect(inspect).to eql('#<OmniAI::OpenAI::Thread::Run id="run-123">') }
  end

  describe "#terminated?" do
    it { expect(described_class.new(client:)).not_to be_terminated }
    it { expect(described_class.new(client:, status: "running")).not_to be_terminated }
    it { expect(described_class.new(client:, status: "cancelled")).to be_terminated }
    it { expect(described_class.new(client:, status: "failed")).to be_terminated }
    it { expect(described_class.new(client:, status: "completed")).to be_terminated }
    it { expect(described_class.new(client:, status: "expired")).to be_terminated }
  end

  describe ".find" do
    subject(:find) { described_class.find(thread_id: "thread-123", id: "run-123", client:) }

    context "with an OK response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/threads/thread-123/runs/run-123")
          .to_return_json(body: {
            id: "run-123",
            assistant_id: "asst-123",
            thread_id: "thread-123",
            status: "completed",
            metadata: { user: "Ringo" },
          })
      end

      it { expect(find.id).to eql("run-123") }
      it { expect(find.assistant_id).to eql("asst-123") }
      it { expect(find.thread_id).to eql("thread-123") }
      it { expect(find.status).to eql("completed") }
      it { expect(find.metadata).to eql("user" => "Ringo") }
    end

    context "with a MISSING response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/threads/thread-123/runs/run-123")
          .to_return_json(status: 404)
      end

      it { expect { find }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe ".all" do
    subject(:all) { described_class.all(thread_id: "thread-123", client:) }

    context "with an OK response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/threads/thread-123/runs")
          .to_return_json(body: {
            data: [
              {
                id: "run-123",
                assistant_id: "asst-123",
                thread_id: "thread-123",
                status: "completed",
                metadata: { user: "Ringo" },
              },
            ],
          })
      end

      it { expect(all).to be_an(Array) }
    end

    context "with a UNPROCESSABLE response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/threads/thread-123/runs")
          .to_return(status: 422)
      end

      it { expect { all }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe ".cancel!" do
    subject(:cancel!) { described_class.cancel!(thread_id: "thread-123", id: "run-123", client:) }

    context "with an OK response" do
      before do
        stub_request(:post, "https://api.openai.com/v1/threads/thread-123/runs/run-123/cancel")
          .to_return_json(body: {
            id: "run-123",
            status: "cancelling",
          })
      end

      it { expect(cancel!["id"]).to eql("run-123") }
      it { expect(cancel!["status"]).to eql("cancelling") }
    end

    context "with a MISSING response" do
      before do
        stub_request(:post, "https://api.openai.com/v1/threads/thread-123/runs/run-123/cancel")
          .to_return_json(status: 404)
      end

      it { expect { cancel! }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe "#cancel!" do
    subject(:cancel!) { run.cancel! }

    let(:run) { described_class.new(client:, id: "run-123", thread_id: "thread-123") }

    context "with an OK response" do
      before do
        stub_request(:post, "https://api.openai.com/v1/threads/thread-123/runs/run-123/cancel")
          .to_return_json(body: {
            id: "run-123",
            status: "cancelling",
          })
      end

      it { expect { cancel! }.to change(run, :status).from(nil).to("cancelling") }
    end

    context "with a MISSING response" do
      before do
        stub_request(:post, "https://api.openai.com/v1/threads/thread-123/runs/run-123/cancel")
          .to_return_json(status: 404)
      end

      it { expect { cancel! }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe "#reload!" do
    subject(:reload!) { run.reload! }

    let(:run) { described_class.new(client:, id: "run-123", thread_id: "thread-123", status: "cancelling") }

    context "with an OK response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/threads/thread-123/runs/run-123")
          .to_return_json(body: {
            id: "run-123",
            status: "cancelled",
          })
      end

      it { expect { reload! }.to change(run, :status).from("cancelling").to("cancelled") }
    end

    context "with a MISSING response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/threads/thread-123/runs/run-123")
          .to_return_json(status: 404)
      end

      it { expect { reload! }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe "#poll!" do
    subject(:poll!) { run.poll!(delay: 0) }

    let(:run) { described_class.new(client:, id: "run-123", thread_id: "thread-123", status: "running") }

    it "calls refetch! continuously until the run is terminated" do
      allow(run).to receive(:terminated?).and_return(false, true)
      allow(run).to receive(:reload!) { run }

      poll!

      expect(run).to have_received(:reload!).twice
    end
  end

  describe "#save!" do
    subject(:save!) { run.save! }

    context "when creating a run" do
      let(:run) { described_class.new(client:, assistant_id: "asst-123", thread_id: "thread-123") }

      context "with an OK response" do
        before do
          stub_request(:post, "https://api.openai.com/v1/threads/thread-123/runs")
            .to_return_json(body: {
              id: "run-123",
              assistant_id: "asst-123",
              thread_id: "thread-123",
              status: "completed",
              metadata: { user: "Ringo" },
            })
        end

        it { expect(save!.id).to eql("run-123") }
        it { expect(save!.assistant_id).to eql("asst-123") }
        it { expect(save!.thread_id).to eql("thread-123") }
        it { expect(save!.status).to eql("completed") }
        it { expect(save!.metadata).to eql("user" => "Ringo") }
      end

      context "with an UNPROCESSABLE response" do
        before do
          stub_request(:post, "https://api.openai.com/v1/threads/thread-123/runs")
            .to_return(status: 422)
        end

        it { expect { save! }.to raise_error(OmniAI::HTTPError) }
      end
    end

    context "when updating a run" do
      let(:run) { described_class.new(client:, id: "run-123", assistant_id: "asst-123", thread_id: "thread-123") }

      context "with an OK response" do
        before do
          stub_request(:post, "https://api.openai.com/v1/threads/thread-123/runs/run-123")
            .to_return_json(body: {
              id: "run-123",
              assistant_id: "asst-123",
              thread_id: "thread-123",
              status: "completed",
              metadata: { user: "Ringo" },
            })
        end

        it { expect(save!.id).to eql("run-123") }
        it { expect(save!.assistant_id).to eql("asst-123") }
        it { expect(save!.thread_id).to eql("thread-123") }
        it { expect(save!.status).to eql("completed") }
        it { expect(save!.metadata).to eql("user" => "Ringo") }
      end

      context "with an UNPROCESSABLE response" do
        before do
          stub_request(:post, "https://api.openai.com/v1/threads/thread-123/runs/run-123")
            .to_return(status: 422)
        end

        it { expect { save! }.to raise_error(OmniAI::HTTPError) }
      end
    end
  end
end
