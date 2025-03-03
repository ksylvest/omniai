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
            id: "fake_id",
            object: "chat.completion.chunk",
            choices: [{ index: 0, delta: { role: "assistant", content: "" } }],
          },
          {
            id: "fake_id",
            object: "chat.completion.chunk",
            choices: [{ index: 0, delta: { content: "Hello" } }],
          },
          {
            id: "completion",
            object: "chat.completion.chunk",
            choices: [{ index: 0, delta: { content: " " } }],
          },
          {
            id: "fake_id",
            object: "chat.completion.chunk",
            choices: [{ index: 0, delta: { content: "World" } }],
          },
        ].map { |chunk| "data: #{JSON.generate(chunk)}\n\n" }
      end

      it "combines multiple chunks" do
        expect(stream!).to eql({
          "id" => "fake_id",
          "choices" => [
            {
              "index" => 0,
              "message" => {
                "role" => "assistant",
                "content" => "Hello World",
              },
            },
          ],
        })
      end

      it "yields multiple times" do
        stream!
        expect(deltas.filter(&:text?).map(&:text)).to eql([
          "Hello",
          " ",
          "World",
        ])
      end
    end

    context "when parsing tool call list chunks" do
      let(:chunks) do
        [
          {
            id: "fake_id",
            object: "chat.completion.chunk",
            choices: [{
              index: 0,
              delta: { role: "assistant", content: nil },
            }],
          },
          {
            id: "fake_id",
            object: "chat.completion.chunk",
            choices: [{
              index: 0,
              delta: { tool_calls: [{ index: 0, id: "a", function: { name: "weather", arguments: "" } }] },
            }],
          },
          {
            id: "fake_id",
            object: "chat.completion.chunk",
            choices: [{
              index: 0,
              delta: { tool_calls: [{ index: 0, function: { arguments: JSON.generate(location: "Madrid") } }] },
            }],
          },
          {
            id: "fake_id",
            object: "chat.completion.chunk",
            choices: [{
              index: 0,
              delta: { tool_calls: [{ index: 1, id: "b", function: { name: "weather", arguments: "" } }] },
            }],
          },
          {
            id: "fake_id",
            object: "chat.completion.chunk",
            choices: [{
              index: 0,
              delta: { tool_calls: [{ index: 1, function: { arguments: JSON.generate(location: "London") } }] },
            }],
          },
          {
            id: "fake_id",
            object: "chat.completion.chunk",
            choices: [{
              index: 0,
              delta: { tool_calls: [{ index: 2, id: "c", function: { name: "weather", arguments: "" } }] },
            }],
          },
          {
            id: "fake_id",
            object: "chat.completion.chunk",
            choices: [{
              index: 0,
              delta: { tool_calls: [{ index: 2, function: { arguments: JSON.generate(location: "Berlin") } }] },
            }],
          },
        ].map { |chunk| "data: #{JSON.generate(chunk)}\n\n" }
      end

      it "combines multiple chunks" do
        expect(stream!).to eql({
          "id" => "fake_id",
          "choices" => [
            {
              "index" => 0,
              "message" => {
                "role" => "assistant",
                "content" => nil,
                "tool_calls" => [
                  {
                    "index" => 0,
                    "id" => "a",
                    "function" => { "name" => "weather", "arguments" => JSON.generate(location: "Madrid") },
                  },
                  {
                    "index" => 1,
                    "id" => "b",
                    "function" => { "name" => "weather", "arguments" => JSON.generate(location: "London") },
                  },
                  {
                    "index" => 2,
                    "id" => "c",
                    "function" => { "name" => "weather", "arguments" => JSON.generate(location: "Berlin") },
                  },
                ],
              },
            },
          ],
        })
      end

      it "does not yield" do
        stream!
        expect(deltas).to eql([])
      end
    end
  end
end
