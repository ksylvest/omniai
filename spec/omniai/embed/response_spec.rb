# frozen_string_literal: true

RSpec.describe OmniAI::Embed::Response do
  subject(:response) { described_class.new(data:, context:) }

  let(:context) { nil }
  let(:data) do
    {
      "data" => [{ "embedding" => [0.0] }],
      "usage" => {
        "prompt_tokens" => 2,
        "total_tokens" => 4,
      },
    }
  end

  describe "#inspect" do
    it { expect(response.inspect).to eql("#<OmniAI::Embed::Response>") }
  end

  describe "#embedding" do
    context "without a context" do
      let(:context) { nil }

      it { expect(response.embedding).to eql([0.0]) }
    end

    context "with a context" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.deserializers[:embeddings] = lambda { |data, *|
            data["data"].map { |entry| entry["embedding"] }
          }
        end
      end

      it { expect(response.embedding).to eql([0.0]) }
    end
  end

  describe "#usage" do
    it { expect(response.usage).to be_a(OmniAI::Embed::Usage) }
    it { expect(response.usage.prompt_tokens).to be(2) }
    it { expect(response.usage.total_tokens).to be(4) }

    context "without a context" do
      let(:context) { nil }

      it { expect(response.usage).to be_a(OmniAI::Embed::Usage) }
      it { expect(response.usage.prompt_tokens).to be(2) }
      it { expect(response.usage.total_tokens).to be(4) }
    end

    context "with a context" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.deserializers[:usage] = lambda { |data, *|
            prompt_tokens = data["usage"]["prompt_tokens"]
            total_tokens = data["usage"]["total_tokens"]
            OmniAI::Embed::Usage.new(prompt_tokens:, total_tokens:)
          }
        end
      end

      it { expect(response.usage).to be_a(OmniAI::Embed::Usage) }
      it { expect(response.usage.prompt_tokens).to be(2) }
      it { expect(response.usage.total_tokens).to be(4) }
    end
  end
end
