# frozen_string_literal: true

RSpec.describe OmniAI::Google::Chat::Stream do
  subject(:stream) { described_class.new(chunks:) }

  describe ".stream!" do
    subject(:stream!) { stream.stream! { |delta| deltas << delta } }

    let(:deltas) { [] }

    context "when parsing text chunks" do
      let(:chunks) do
        [
          {
            candidates: [
              {
                content: {
                  role: "model",
                  parts: [{ text: "Hello" }],
                },
                index: 0,
              },
            ],
          },
          {
            candidates: [
              {
                content: {
                  role: "model",
                  parts: [{ text: " " }],
                },
                index: 0,
              },
            ],
          },
          {
            candidates: [
              {
                content: {
                  role: "model",
                  parts: [{ text: "World" }],
                },
                index: 0,
              },
            ],
          },
        ].map { |chunk| "data: #{JSON.generate(chunk)}\n\n" }
      end

      it "combines multiple chunks" do
        expect(stream!).to eql({
          "candidates" => [
            {
              "content" => {
                "role" => "model",
                "parts" => [
                  {
                    "text" => "Hello World",
                  },
                ],
              },
              "index" => 0,
            },
          ],
        })
      end

      it "yields multiple times" do
        stream!
        expect(deltas.map(&:text)).to eql([
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
            candidates: [
              {
                content: {
                  role: "model",
                  parts: [
                    {
                      functionCall: { name: "weather", arguments: JSON.generate(location: "Madrid") },
                    },
                  ],
                },
                index: 0,
              },
            ],
          },
          {
            candidates: [
              {
                content: {
                  role: "model",
                  parts: [
                    {
                      functionCall: { name: "weather", arguments: JSON.generate(location: "London") },
                    },
                  ],
                },
                index: 0,
              },
            ],
          },
          {
            candidates: [
              {
                content: {
                  role: "model",
                  parts: [
                    {
                      functionCall: { name: "weather", arguments: JSON.generate(location: "Berlin") },
                    },
                  ],
                },
                index: 0,
              },
            ],
          },
        ].map { |chunk| "data: #{JSON.generate(chunk)}\n\n" }
      end

      it "combines multiple chunks" do
        expect(stream!).to eql({
          "candidates" => [
            {
              "content" => {
                "role" => "model",
                "parts" => [
                  {
                    "functionCall" => {
                      "name" => "weather",
                      "arguments" => JSON.generate(location: "Madrid"),
                    },
                  },
                  {
                    "functionCall" => {
                      "name" => "weather",
                      "arguments" => JSON.generate(location: "London"),
                    },
                  },
                  {
                    "functionCall" => {
                      "name" => "weather",
                      "arguments" => JSON.generate(location: "Berlin"),
                    },
                  },
                ],
              },
              "index" => 0,
            },
          ],
        })
      end

      it "does not yield" do
        stream!
        expect(deltas).to eql([])
      end
    end

    context "when parsing text and tool call list chunks" do
      let(:chunks) do
        [
          {
            candidates: [
              {
                content: {
                  role: "model",
                  parts: [{ text: "Hello" }],
                },
                index: 0,
              },
            ],
          },
          {
            candidates: [
              {
                content: {
                  role: "model",
                  parts: [{ text: " " }],
                },
                index: 0,
              },
            ],
          },
          {
            candidates: [
              {
                content: {
                  role: "model",
                  parts: [{ text: "World" }],
                },
                index: 0,
              },
            ],
          },
          {
            candidates: [
              {
                content: {
                  role: "model",
                  parts: [
                    {
                      functionCall: { name: "weather", arguments: JSON.generate(location: "Madrid") },
                    },
                  ],
                },
                index: 0,
              },
            ],
          },
          {
            candidates: [
              {
                content: {
                  role: "model",
                  parts: [
                    {
                      functionCall: { name: "weather", arguments: JSON.generate(location: "London") },
                    },
                  ],
                },
                index: 0,
              },
            ],
          },
          {
            candidates: [
              {
                content: {
                  role: "model",
                  parts: [
                    {
                      functionCall: { name: "weather", arguments: JSON.generate(location: "Berlin") },
                    },
                  ],
                },
                index: 0,
              },
            ],
          },
        ].map { |chunk| "data: #{JSON.generate(chunk)}\n\n" }
      end

      it "combines multiple chunks" do
        expect(stream!).to eql({
          "candidates" => [
            {
              "content" => {
                "role" => "model",
                "parts" => [
                  {
                    "text" => "Hello World",
                  },
                  {
                    "functionCall" => {
                      "name" => "weather",
                      "arguments" => JSON.generate(location: "Madrid"),
                    },
                  },
                  {
                    "functionCall" => {
                      "name" => "weather",
                      "arguments" => JSON.generate(location: "London"),
                    },
                  },
                  {
                    "functionCall" => {
                      "name" => "weather",
                      "arguments" => JSON.generate(location: "Berlin"),
                    },
                  },
                ],
              },
              "index" => 0,
            },
          ],
        })
      end

      it "yields multiple times" do
        stream!
        expect(deltas.map(&:text)).to eql([
          "Hello",
          " ",
          "World",
        ])
      end
    end
  end
end
