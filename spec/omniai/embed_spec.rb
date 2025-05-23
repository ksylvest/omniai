# frozen_string_literal: true

class FakeEmbed < OmniAI::Embed
  module Model
    FAKE = "fake"
  end

  def path
    "/embed"
  end

  def params
    { api_key: "fake-api-key" }
  end

  def payload
    { input: @input, model: @model }
  end
end

RSpec.describe OmniAI::Embed do
  subject(:embed) { described_class.new(input, model:, client:) }

  let(:input) { "The quick brown fox jumps over a lazy dog." }
  let(:model) { "..." }
  let(:client) { build(:client) }

  describe "#path" do
    it { expect { embed.send(:path) }.to raise_error(NotImplementedError) }
  end

  describe "#payload" do
    it { expect { embed.send(:payload) }.to raise_error(NotImplementedError) }
  end

  describe ".process!" do
    subject(:process!) { FakeEmbed.process!(input, model:, client:) }

    let(:model) { FakeChat::Model::FAKE }

    context "when OK" do
      before do
        stub_request(:post, "http://localhost:8080/embed?api_key=fake-api-key")
          .with(body: {
            input:,
            model:,
          })
          .to_return_json(status: 200, body: {
            data: [
              { index: 0, embedding: [0.0] },
            ],
            usage: { prompt_tokens: 2, total_tokens: 4 },
          })
      end

      it { expect(process!).to be_a(OmniAI::Embed::Response) }
    end

    context "when UNPROCESSABLE" do
      before do
        stub_request(:post, "http://localhost:8080/embed?api_key=fake-api-key")
          .with(body: {
            input:,
            model:,
          })
          .to_return(status: 422, body: "An unknown error occurred.")
      end

      it { expect { process! }.to raise_error(OmniAI::Error) }
    end
  end
end
