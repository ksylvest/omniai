# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Delta do
  describe "#initialize" do
    it "accepts text" do
      delta = described_class.new(text: "hello")
      expect(delta.text).to eq("hello")
    end

    it "accepts thinking" do
      delta = described_class.new(thinking: "reasoning...")
      expect(delta.thinking).to eq("reasoning...")
    end

    it "defaults to nil for both" do
      delta = described_class.new
      expect(delta.text).to be_nil
      expect(delta.thinking).to be_nil
    end
  end

  describe "#text?" do
    it "returns true when text is present" do
      delta = described_class.new(text: "hello")
      expect(delta.text?).to be true
    end

    it "returns false when text is nil" do
      delta = described_class.new(thinking: "thinking")
      expect(delta.text?).to be false
    end

    it "returns false when text is empty" do
      delta = described_class.new(text: "")
      expect(delta.text?).to be false
    end
  end

  describe "#thinking?" do
    it "returns true when thinking is present" do
      delta = described_class.new(thinking: "reasoning...")
      expect(delta.thinking?).to be true
    end

    it "returns false when thinking is nil" do
      delta = described_class.new(text: "hello")
      expect(delta.thinking?).to be false
    end

    it "returns false when thinking is empty" do
      delta = described_class.new(thinking: "")
      expect(delta.thinking?).to be false
    end
  end
end
