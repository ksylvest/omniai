# frozen_string_literal: true

RSpec.describe OmniAI::Google::Chat::UsageSerializer do
  let(:context) { OmniAI::Google::Chat::CONTEXT }

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) do
      {
        "promptTokenCount" => 2,
        "candidatesTokenCount" => 3,
        "totalTokenCount" => 5,
      }
    end

    it { expect(deserialize).to be_a(OmniAI::Chat::Usage) }
    it { expect(deserialize.input_tokens).to be(2) }
    it { expect(deserialize.output_tokens).to be(3) }
    it { expect(deserialize.total_tokens).to be(5) }
  end

  describe ".serialize" do
    subject(:serialize) { described_class.serialize(usage, context:) }

    let(:usage) { OmniAI::Chat::Usage.new(input_tokens: 2, output_tokens: 3, total_tokens: 5) }

    it { expect(serialize).to eql(promptTokenCount: 2, candidatesTokenCount: 3, totalTokenCount: 5) }
  end
end
