# frozen_string_literal: true

RSpec.describe OmniAI::Anthropic::Chat::ContentSerializer do
  let(:context) { OmniAI::Anthropic::Chat::CONTEXT }

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    context "with text" do
      let(:data) do
        {
          "type" => "text",
          "text" => "Hello!",
        }
      end

      it { is_expected.to be_a(OmniAI::Chat::Text) }
    end

    context "with tool-call" do
      let(:data) do
        {
          "type" => "tool_use",
          "id" => "fake_tool_call_id",
          "name" => "temperature",
          "input" => { "unit" => "celsius" },
        }
      end

      it { is_expected.to be_a(OmniAI::Chat::ToolCall) }
    end
  end
end
