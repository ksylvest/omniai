# frozen_string_literal: true

RSpec.describe OmniAI::Chat::ToolCallList do
  subject(:tool_call_list) { build(:chat_tool_call_list, entries: [tool_call]) }

  let(:tool_call) { build(:chat_tool_call) }

  describe "#inspect" do
    subject(:inspect) { tool_call_list.inspect }

    it { expect(inspect).to eql("#<OmniAI::Chat::ToolCallList entries=[#{tool_call.inspect}]>") }
  end

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data) }

    let(:data) do
      [
        {
          "index" => 0,
          "type" => "function",
          "function" => { "name" => "weather", "arguments" => JSON.generate(location: "Berlin") },
        },
        {
          "index" => 1,
          "type" => "function",
          "function" => { "name" => "weather", "arguments" => JSON.generate(location: "London") },
        },
        {
          "index" => 2,
          "type" => "function",
          "function" => { "name" => "weather", "arguments" => JSON.generate(location: "Madrid") },
        },
      ]
    end

    it { expect(deserialize).to be_a(described_class) }
    it { expect(deserialize.count).to be(3) }
    it { expect(deserialize).to all(be_a(OmniAI::Chat::ToolCall)) }
  end

  describe "#serialize" do
    subject(:serialize) { tool_call_list.serialize }

    it { expect(serialize).to eql([tool_call.serialize]) }
  end
end
