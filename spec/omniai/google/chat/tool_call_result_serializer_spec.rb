# frozen_string_literal: true

RSpec.describe OmniAI::Google::Chat::ToolCallResultSerializer do
  let(:context) { OmniAI::Google::Chat::CONTEXT }

  describe ".serialize" do
    subject(:serialize) { described_class.serialize(tool_call_result, context:) }

    let(:tool_call_result) { OmniAI::Chat::ToolCallResult.new(tool_call_id: "temperature", content: "20") }

    let(:data) do
      {
        functionResponse: {
          name: "temperature",
          response: {
            name: "temperature",
            content: "20",
          },
        },
      }
    end

    it { expect(serialize).to eql(data) }
  end

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) do
      {
        "functionResponse" => {
          "name" => "temperature",
          "response" => {
            "name" => "temperature",
            "content" => "20",
          },
        },
      }
    end

    it { expect(deserialize).to be_a(OmniAI::Chat::ToolCallResult) }
    it { expect(deserialize.tool_call_id).to eql("temperature") }
    it { expect(deserialize.content).to eql("20") }
  end
end
