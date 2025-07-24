# frozen_string_literal: true

RSpec.describe OmniAI::Anthropic::Chat::ChoiceSerializer do
  let(:context) { OmniAI::Anthropic::Chat::CONTEXT }

  describe ".serialize" do
    subject(:serialize) { described_class.serialize(choice, context:) }

    let(:choice) { OmniAI::Chat::Choice.new(message:) }
    let(:message) { OmniAI::Chat::Message.new(role: "user", content: [text]) }
    let(:text) { OmniAI::Chat::Text.new("Greetings!") }

    let(:data) do
      {
        role: "user",
        content: [
          {
            text: "Greetings!",
            type: "text",
          },
        ],
      }
    end

    it { is_expected.to eql(data) }
  end

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) do
      {
        "role" => "user",
        "content" => [
          {
            "text" => "Greetings!",
            "type" => "text",
          },
        ],
      }
    end

    it { is_expected.to be_a(OmniAI::Chat::Choice) }
  end
end
