# frozen_string_literal: true

RSpec.describe OmniAI::Google::Chat::ToolCallSerializer do
  let(:context) { OmniAI::Google::Chat::CONTEXT }

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) do
      {
        "functionCall" => {
          "name" => "temperature",
          "args" => { "unit" => "celsius" },
        },
      }
    end

    it { expect(deserialize).to be_a(OmniAI::Chat::ToolCall) }
  end

  describe ".serialize" do
    subject(:serialize) { described_class.serialize(tool_call, context:) }

    let(:tool_call) { OmniAI::Chat::ToolCall.new(id: "temperature", function:) }
    let(:function) { OmniAI::Google::Chat::Function.new(name: "temperature", arguments: { unit: "celsius" }) }

    it { expect(serialize).to eql(functionCall: { name: "temperature", args: { unit: "celsius" } }) }
  end
end
