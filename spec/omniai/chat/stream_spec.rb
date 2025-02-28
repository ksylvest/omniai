# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Stream do
  subject(:stream) { build(:chat_stream, chunks:) }

  describe ".stream!" do
    subject(:stream!) { stream.stream! { |delta| deltas << delta } }

    let(:deltas) { [] }

    context "when parsing text chunks" do
      let(:chunks) do
        [
          {
            id: "completion",
            object: "chat.completion.chunk",
            choices: [{ index: 0, delta: { role: "assistant", content: "" } }],
          },
          {
            id: "completion",
            object: "chat.completion.chunk",
            choices: [{ index: 0, delta: { content: "Hello" } }],
          },
          {
            id: "completion",
            object: "chat.completion.chunk",
            choices: [{ index: 0, delta: { content: " " } }],
          },
          {
            id: "completion",
            object: "chat.completion.chunk",
            choices: [{ index: 0, delta: { content: "World" } }],
          },
        ].map { |chunk| "data: #{JSON.generate(chunk)}\n\n" }
      end

      it { expect(stream!).to be_a(OmniAI::Chat::Payload) }
      it { expect(stream!.text).to eql("Hello World") }
    end

    context "when parsing tool call list chunks" do
      let(:chunks) do
        [
          {
            id: "completion",
            object: "chat.completion.chunk",
            choices: [{
              index: 0,
              delta: { role: "assistant", content: nil },
            }],
          },
          {
            id: "completion",
            object: "chat.completion.chunk",
            choices: [{
              index: 0,
              delta: { tool_calls: [{ index: 0, id: "a", function: { name: "weather", arguments: "" } }] },
            }],
          },
          {
            id: "completion",
            object: "chat.completion.chunk",
            choices: [{
              index: 0,
              delta: { tool_calls: [{ index: 0, function: { arguments: JSON.generate(location: "Madrid") } }] },
            }],
          },
          {
            id: "completion",
            object: "chat.completion.chunk",
            choices: [{
              index: 0,
              delta: { tool_calls: [{ index: 1, id: "b", function: { name: "weather", arguments: "" } }] },
            }],
          },
          {
            id: "completion",
            object: "chat.completion.chunk",
            choices: [{
              index: 0,
              delta: { tool_calls: [{ index: 1, function: { arguments: JSON.generate(location: "London") } }] },
            }],
          },
          {
            id: "completion",
            object: "chat.completion.chunk",
            choices: [{
              index: 0,
              delta: { tool_calls: [{ index: 2, id: "c", function: { name: "weather", arguments: "" } }] },
            }],
          },
          {
            id: "completion",
            object: "chat.completion.chunk",
            choices: [{
              index: 0,
              delta: { tool_calls: [{ index: 2, function: { arguments: JSON.generate(location: "Berlin") } }] },
            }],
          },
        ].map { |chunk| "data: #{JSON.generate(chunk)}\n\n" }
      end

      it { expect(stream!).to be_a(OmniAI::Chat::Payload) }
      it { expect(stream!.tool_call_list).to be_a(OmniAI::Chat::ToolCallList) }
      it { expect(stream!.tool_call_list.count).to be(3) }
    end
  end
end
