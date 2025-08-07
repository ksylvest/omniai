# frozen_string_literal: true

RSpec.describe OmniAI::Google::Embed do
  let(:client) { OmniAI::Google::Client.new }
  let(:project_id) { "fake" }

  describe ".process!" do
    subject(:process!) { described_class.process!(text, client:, model:) }

    let(:text) { "The quick brown fox jumps over a lazy dog." }
    let(:model) { described_class::DEFAULT_MODEL }
    let(:location) { OmniAI::Google::Config::DEFAULT_LOCATION }

    before do
      stub_request(:post, "https://generativelanguage.googleapis.com//v1beta/models/text-embedding-004:batchEmbedContents?key=#{client.api_key}")
        .with(body: {
          requests: [
            {
              model: "models/#{model}",
              content: { parts: [{ text: }] },
            },
          ],
        })
        .to_return_json(body: { embeddings: [{ values: [0.0] }] })
    end

    it { expect(process!).to be_a(OmniAI::Embed::Response) }
    it { expect(process!.embedding).to eql([0.0]) }
  end
end
