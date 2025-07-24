# frozen_string_literal: true

RSpec.describe OmniAI::Anthropic::Chat::Stream do
  subject(:stream) { described_class.new(chunks:) }

  describe ".stream!" do
    subject(:stream!) { stream.stream! { |delta| deltas << delta } }

    let(:deltas) { [] }

    let(:chunks) do
      [
        {
          event: "message_start",
          data: {
            type: "message_start",
            message: {
              id: "fake_id",
              role: "assistant",
              content: [],
              usage: {
                input_tokens: 0,
                output_tokens: 0,
              },
            },
          },
        },
        {
          event: "content_block_start",
          data: {
            type: "content_block_start",
            index: 0,
            content_block: { type: "text", text: "" },
          },
        },
        {

          event: "content_block_delta",
          data: {
            type: "content_block_delta",
            index: 0,
            delta: { type: "text_delta", text: "Hello" },
          },
        },
        {
          event: "content_block_delta",
          data: {
            type: "content_block_delta",
            index: 0,
            delta: { type: "text_delta", text: " " },
          },
        },
        {
          event: "content_block_delta",
          data: {
            type: "content_block_delta",
            index: 0,
            delta: { type: "text_delta", text: "World" },
          },
        },
        {
          event: "content_block_stop",
          data: {
            type: "content_block_stop",
            index: 0,
          },
        },
        {
          event: "content_block_start",
          data: {
            type: "content_block_start",
            index: 1,
            content_block: { type: "tool_use", id: "tool_use_1", name: "weather", input: {} },
          },
        },
        {
          event: "content_block_delta",
          data: {
            type: "content_block_delta",
            index: 1,
            delta: { type: "input_json_delta", partial_json: "" },
          },
        },
        {
          event: "content_block_delta",
          data: {
            type: "content_block_delta",
            index: 1,
            delta: { type: "input_json_delta", partial_json: "{" },
          },
        },
        {
          event: "content_block_delta",
          data: {
            type: "content_block_delta",
            index: 1,
            delta: { type: "input_json_delta", partial_json: '"location": "London"' },
          },
        },
        {
          event: "content_block_delta",
          data: {
            type: "content_block_delta",
            index: 1,
            delta: { type: "input_json_delta", partial_json: "}" },
          },
        },
        {
          event: "content_block_stop",
          data: {
            type: "content_block_stop",
            index: 1,
          },
        },
        {
          event: "content_block_start",
          data: {
            type: "content_block_start",
            index: 2,
            content_block: { type: "tool_use", id: "tool_use_1", name: "weather", input: {} },
          },
        },
        {
          event: "content_block_delta",
          data: {
            type: "content_block_delta",
            index: 2,
            delta: { type: "input_json_delta", partial_json: "" },
          },
        },
        {
          event: "content_block_delta",
          data: {
            type: "content_block_delta",
            index: 2, delta: { type: "input_json_delta", partial_json: "{" },
          },
        },
        {
          event: "content_block_delta",
          data: {
            type: "content_block_delta",
            index: 2,
            delta: { type: "input_json_delta", partial_json: '"location": "Madrid"' },
          },
        },
        {
          event: "content_block_delta",
          data: {
            type: "content_block_delta",
            index: 2, delta: { type: "input_json_delta", partial_json: "}" },
          },
        },
        {
          event: "content_block_stop",
          data: {
            type: "content_block_stop",
            index: 2,
          },
        },
        {
          event: "message_delta",
          data: {
            type: "message_delta",
            delta: {},
            usage: {
              input_tokens: 4,
              output_tokens: 8,
            },
          },
        },
        {
          event: "message_stop",
          data: {
            type: "message_stop",
          },
        },
      ].map { |chunk| "event: #{chunk[:event]}\ndata: #{JSON.generate(chunk[:data])}\n\n" }
    end

    it "combines multiple chunks" do
      expect(stream!).to eql({
        "id" => "fake_id",
        "role" => "assistant",
        "content" => [
          { "type" => "text", "text" => "Hello World" },
          { "type" => "tool_use", "id" => "tool_use_1", "name" => "weather", "input" => { "location" => "London" } },
          { "type" => "tool_use", "id" => "tool_use_1", "name" => "weather", "input" => { "location" => "Madrid" } },
        ],
        "usage" => {
          "input_tokens" => 4,
          "output_tokens" => 8,
        },
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
end
