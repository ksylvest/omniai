# frozen_string_literal: true

class FakeSpeak < OmniAI::Speak
  module Model
    FAKE = "fake"
  end

  def path
    "/speak"
  end
end

RSpec.describe OmniAI::Speak do
  subject(:transcribe) { described_class.new(text, model:, client:, voice:) }

  let(:model) { "..." }
  let(:client) { build(:client) }
  let(:text) { "The quick brown fox jumps over a lazy dog." }
  let(:voice) { "hal" }

  describe "#path" do
    it { expect { transcribe.send(:path) }.to raise_error(NotImplementedError) }
  end

  describe ".process!" do
    let(:model) { FakeSpeak::Model::FAKE }

    context "with a block" do
      subject(:process!) { FakeSpeak.process!(text, client:, model:, voice:) { |chunk| io << chunk } }

      let(:io) { StringIO.new }

      context "when OK" do
        before do
          stub_request(:post, "http://localhost:8080/speak")
            .to_return(status: 200, body: "...")
        end

        it do
          process!
          expect(io.string).to eq("...")
        end
      end

      context "when UNPROCESSABLE" do
        before do
          stub_request(:post, "http://localhost:8080/speak")
            .to_return(status: 422, body: "An unknown error occurred.")
        end

        it { expect { process! }.to raise_error(OmniAI::HTTPError) }
      end
    end

    context "without a block" do
      subject(:process!) { FakeSpeak.process!(text, client:, model:, voice:) }

      context "when OK" do
        before do
          stub_request(:post, "http://localhost:8080/speak")
            .to_return(status: 200, body: "...")
        end

        it do
          tempfile = process!
          expect(tempfile).to be_a(Tempfile)
          tempfile.close
          tempfile.unlink
        end
      end

      context "when UNPROCESSABLE" do
        before do
          stub_request(:post, "http://localhost:8080/speak")
            .to_return(status: 422, body: "An unknown error occurred.")
        end

        it { expect { process! }.to raise_error(OmniAI::HTTPError) }
      end
    end
  end
end
