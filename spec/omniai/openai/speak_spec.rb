# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Speak do
  let(:client) { OmniAI::OpenAI::Client.new }

  describe ".process!" do
    subject(:process!) { described_class.process!(input, client:, model:, voice:) }

    let(:voice) { described_class::Voice::ALLOY }
    let(:model) { described_class::Model::TTS_1_HD }
    let(:input) { "The quick brown fox jumps over a lazy dog." }

    before do
      stub_request(:post, "https://api.openai.com/v1/audio/speech")
        .with(body: { model:, voice:, input:, response_format: "aac" })
        .to_return(body: "...")
    end

    it do
      tempfile = process!
      expect(tempfile).to be_a(Tempfile)
      tempfile.close
      tempfile.unlink
    end
  end
end
