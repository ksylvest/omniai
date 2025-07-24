# frozen_string_literal: true

RSpec.describe OmniAI::Google::Chat::TextSerializer do
  let(:context) { OmniAI::Google::Chat::CONTEXT }

  describe ".serialize" do
    subject(:serialize) { described_class.serialize(text) }

    let(:text) { OmniAI::Chat::Text.new("Greetings!") }

    it { is_expected.to eql(text: "Greetings!") }
  end

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) { { "text" => "Greetings!" } }

    it { is_expected.to be_a(OmniAI::Chat::Text) }
  end
end
