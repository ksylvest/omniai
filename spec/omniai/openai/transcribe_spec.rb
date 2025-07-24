# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Transcribe do
  let(:client) { OmniAI::OpenAI::Client.new }
  let(:model) { described_class::Model::WHISPER }

  describe ".process!" do
    subject(:transcription) { described_class.process!(path, client:, model:, format:) }

    let(:path) { Pathname.new(File.dirname(__FILE__)).join("..", "..", "fixtures", "file.ogg") }

    context "with JSON format" do
      let(:format) { described_class::Format::JSON }

      before do
        stub_request(:post, "https://api.openai.com/v1/audio/transcriptions")
          .to_return_json(body: { text: "The quick brown fox jumps over a lazy dog." })
      end

      it { expect(transcription.text).to eql("The quick brown fox jumps over a lazy dog.") }
    end

    context "with TEXT format" do
      let(:format) { described_class::Format::TEXT }

      before do
        stub_request(:post, "https://api.openai.com/v1/audio/transcriptions")
          .to_return(body: "The quick brown fox jumps over a lazy dog.")
      end

      it { expect(transcription.text).to eql("The quick brown fox jumps over a lazy dog.") }
    end
  end
end
