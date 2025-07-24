# frozen_string_literal: true

RSpec.describe OmniAI::Mistral::Embed do
  let(:client) { OmniAI::Mistral::Client.new }

  describe ".process!" do
    subject(:process!) { described_class.process!(input, client:, model:) }

    let(:input) { "The quick brown fox jumps over a lazy dog." }
    let(:model) { described_class::DEFAULT_MODEL }

    before do
      stub_request(:post, "https://api.mistral.ai/v1/embeddings")
        .with(body: {
          input: [input],
          model:,
        })
        .to_return_json(body: {
          data: [{ embedding: [0.0] }],
          usage: {
            prompt_tokens: 4,
            total_tokens: 8,
          },
        })
    end

    it { expect(process!).to be_a(OmniAI::Embed::Response) }
    it { expect(process!.embedding).to eql([0.0]) }
    it { expect(process!.usage.prompt_tokens).to be(4) }
    it { expect(process!.usage.total_tokens).to be(8) }
  end
end
