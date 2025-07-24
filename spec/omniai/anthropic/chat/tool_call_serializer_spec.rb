# frozen_string_literal: true

RSpec.describe OmniAI::Anthropic::Chat::ToolCallSerializer do
  let(:context) { OmniAI::Anthropic::Chat::CONTEXT }

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) do
      {
        "type" => "tool_use",
        "id" => "fake_tool_call_id",
        "name" => "temperature",
        "input" => { "unit" => "celsius" },
      }
    end

    it { expect(deserialize).to be_a(OmniAI::Chat::ToolCall) }
  end

  describe "#serialize" do
    subject(:serialize) { described_class.serialize(tool_call, context:) }

    let(:tool_call) { OmniAI::Chat::ToolCall.new(id: "fake_id", function:) }
    let(:function) { OmniAI::Chat::Function.new(name: "temperature", arguments: { unit: "celsius" }) }

    it {
      expect(serialize).to eql(type: "tool_use", id: "fake_id", name: "temperature", input: { unit: "celsius" })
    }
  end
end
