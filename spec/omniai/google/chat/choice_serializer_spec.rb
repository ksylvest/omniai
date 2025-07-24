# frozen_string_literal: true

RSpec.describe OmniAI::Google::Chat::ChoiceSerializer do
  let(:context) { OmniAI::Google::Chat::CONTEXT }

  describe ".serialize" do
    subject(:serialize) { described_class.serialize(choice, context:) }

    let(:choice) { OmniAI::Chat::Choice.new(message:) }
    let(:message) { OmniAI::Chat::Message.new(role: "user", content: "Greetings!") }

    it { is_expected.to eql(content: { role: "user", parts: [{ text: "Greetings!" }] }) }
  end

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) do
      {
        "content" => {
          "role" => "user",
          "parts" => [{ "text" => "Greetings!" }],
        },
      }
    end

    it { is_expected.to be_a(OmniAI::Chat::Choice) }
  end
end
