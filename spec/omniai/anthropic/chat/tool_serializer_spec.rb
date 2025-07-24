# frozen_string_literal: true

RSpec.describe OmniAI::Anthropic::Chat::ToolSerializer do
  let(:context) { OmniAI::Anthropic::Chat::CONTEXT }

  describe "#serialize" do
    subject(:serialize) { tool.serialize(context:) }

    let(:tool) do
      OmniAI::Tool.new(
        -> { "..." },
        name: "weather",
        description: "Finds the current weather",
        parameters: OmniAI::Schema.object(
          properties: {
            location: OmniAI::Schema.string,
          },
          required: ["location"]
        )
      )
    end

    it "serializes the tool" do
      expect(serialize).to eql({
        name: "weather",
        description: "Finds the current weather",
        input_schema: {
          type: "object",
          properties: {
            location: { type: "string" },
          },
          required: ["location"],
        },
      })
    end
  end
end
