# frozen_string_literal: true

class FakeTranscribe < OmniAI::Transcribe
  module Model
    FAKE = "fake"
  end

  def path
    "/transcribe"
  end
end

RSpec.describe OmniAI::Transcribe do
  subject(:transcribe) { described_class.new(io, model:, client:) }

  let(:model) { "..." }
  let(:client) { build(:client) }
  let(:io) { Pathname.new(File.dirname(__FILE__)).join("..", "fixtures", "file.ogg") }

  describe "#path" do
    it { expect { transcribe.send(:path) }.to raise_error(NotImplementedError) }
  end

  describe ".process!" do
    subject(:process!) { FakeTranscribe.process!(io, client:, model:, format:) }

    let(:format) { described_class::Format::JSON }

    let(:model) { FakeTranscribe::Model::FAKE }

    context "when OK" do
      before do
        stub_request(:post, "http://localhost:8080/transcribe")
          .to_return_json(status: 200, body: {
            text: "Hi!",
          })
      end

      it { expect(process!).to be_a(OmniAI::Transcribe::Transcription) }
      it { expect(process!.text).to eq("Hi!") }
    end

    context "when UNPROCESSABLE" do
      before do
        stub_request(:post, "http://localhost:8080/transcribe")
          .to_return(status: 422, body: "An unknown error occurred.")
      end

      it { expect { process! }.to raise_error(OmniAI::HTTPError) }
    end

    context "when OK with a non-JSON format" do
      before do
        stub_request(:post, "http://localhost:8080/transcribe")
          .to_return(status: 200, body: "Hi!")
      end

      let(:format) { described_class::Format::TEXT }

      it { expect(process!).to be_a(OmniAI::Transcribe::Transcription) }
      it { expect(process!.text).to eq("Hi!") }
    end
  end
end
