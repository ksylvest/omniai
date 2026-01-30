# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Thinking do
  describe "#initialize" do
    it "accepts thinking text" do
      thinking = described_class.new("I should think about this...")
      expect(thinking.thinking).to eq("I should think about this...")
    end

    it "accepts metadata" do
      thinking = described_class.new("thinking", metadata: { signature: "abc123" })
      expect(thinking.metadata).to eq({ signature: "abc123" })
    end

    it "defaults metadata to empty hash" do
      thinking = described_class.new("thinking")
      expect(thinking.metadata).to eq({})
    end

    it "handles nil metadata" do
      thinking = described_class.new("thinking", metadata: nil)
      expect(thinking.metadata).to eq({})
    end
  end

  describe "#inspect" do
    it "returns a string representation" do
      thinking = described_class.new("test thinking")
      expect(thinking.inspect).to eq('#<OmniAI::Chat::Thinking thinking="test thinking">')
    end
  end

  describe "#summarize" do
    it "returns the thinking text" do
      thinking = described_class.new("my thoughts")
      expect(thinking.summarize).to eq("my thoughts")
    end
  end

  describe "#serialize" do
    it "returns hash with type and thinking" do
      thinking = described_class.new("test thinking")
      expect(thinking.serialize).to eq({ type: "thinking", thinking: "test thinking" })
    end

    it "uses context serializer when available" do
      custom_serializer = ->(thinking, context:) { { custom: thinking.thinking } } # rubocop:disable Lint/UnusedBlockArgument
      context = OmniAI::Context.build do |ctx|
        ctx.serializers[:thinking] = custom_serializer
      end

      thinking = described_class.new("test")
      expect(thinking.serialize(context:)).to eq({ custom: "test" })
    end
  end

  describe ".deserialize" do
    it "creates Thinking from hash" do
      data = { "thinking" => "test" }
      thinking = described_class.deserialize(data)
      expect(thinking.thinking).to eq("test")
    end

    it "uses context deserializer when available" do
      custom_deserializer = ->(data, context:) { described_class.new("custom: #{data['thinking']}") } # rubocop:disable Lint/UnusedBlockArgument
      context = OmniAI::Context.build do |ctx|
        ctx.deserializers[:thinking] = custom_deserializer
      end

      data = { "thinking" => "test" }
      thinking = described_class.deserialize(data, context:)
      expect(thinking.thinking).to eq("custom: test")
    end
  end
end
