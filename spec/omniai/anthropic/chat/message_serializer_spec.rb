# frozen_string_literal: true

RSpec.describe OmniAI::Anthropic::Chat::MessageSerializer do
  let(:context) { OmniAI::Anthropic::Chat::CONTEXT }

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) do
      {
        "role" => "user",
        "content" => [{ "type" => "text", "text" => "Hello!" }],
      }
    end

    it { expect(deserialize).to be_a(OmniAI::Chat::Message) }
    it { expect(deserialize.role).to eql("user") }
    it { expect(deserialize.text).to eql("Hello!") }
  end

  describe "#serialize" do
    subject(:serialize) { described_class.serialize(message, context:) }

    let(:message) { OmniAI::Chat::Message.new(content: "Hello!") }

    it { expect(serialize).to eql(role: "user", content: [{ type: "text", text: "Hello!" }]) }
  end
end
