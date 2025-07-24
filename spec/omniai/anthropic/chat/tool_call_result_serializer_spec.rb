# frozen_string_literal: true

RSpec.describe OmniAI::Anthropic::Chat::ToolCallResultSerializer do
  let(:context) { OmniAI::Anthropic::Chat::CONTEXT }

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) do
      {
        "type" => "tool_result",
        "tool_use_id" => "fake_id",
        "content" => "Hello!",
      }
    end

    it { expect(deserialize).to be_a(OmniAI::Chat::ToolCallResult) }
    it { expect(deserialize.tool_call_id).to eql("fake_id") }
    it { expect(deserialize.content).to eql("Hello!") }
  end

  describe "#serialize" do
    subject(:serialize) { described_class.serialize(tool_call_result, context:) }

    let(:tool_call_result) { OmniAI::Chat::ToolCallResult.new(content: "Hello!", tool_call_id: "fake_id") }
    let(:function) { OmniAI::Chat::Function.new(name: "temperature", arguments: { unit: "celsius" }) }

    it { expect(serialize).to eql(type: "tool_result", tool_use_id: "fake_id", content: "Hello!") }
  end
end
