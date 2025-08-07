# frozen_string_literal: true

RSpec.describe OmniAI::Google::Chat::MessageSerializer do
  let(:context) { OmniAI::Google::Chat::CONTEXT }

  describe ".serialize" do
    subject(:serialize) { described_class.serialize(message, context:) }

    let(:message) { OmniAI::Chat::Message.new(role: "user", content: "Greetings!") }

    it { is_expected.to eql(role: "user", parts: [{ text: "Greetings!" }]) }
  end

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) do
      {
        "role" => "USER",
        "parts" => [
          { "text" => "Greetings!" },
          {
            "functionCall" => {
              "name" => "weather",
              "args" => { "location" => "Vancouver" },
            },
          },
          {
            "functionCall" => {
              "name" => "weather",
              "args" => { "location" => "Toronto" },
            },
          },
        ],
      }
    end

    it { is_expected.to be_a(OmniAI::Chat::Message) }
  end
end
