# frozen_string_literal: true

RSpec.describe OmniAI::Chat::FinishReason do
  describe ".deserialize" do
    let(:table) { { "stop" => :stop, "length" => :length } }

    context "when the value is nil" do
      it "returns nil (absence is not :other)" do
        expect(described_class.deserialize(nil, table:)).to be_nil
      end
    end

    context "when the value is in the table" do
      subject(:finish_reason) { described_class.deserialize("length", table:) }

      it { expect(finish_reason).to be_a(described_class) }
      it { expect(finish_reason.reason).to eq(:length) }
      it { expect(finish_reason.value).to eq("length") }
    end

    context "when the value is present but not in the table" do
      subject(:finish_reason) { described_class.deserialize("supernova", table:) }

      it "normalizes the reason to :other" do
        expect(finish_reason.reason).to eq(:other)
      end

      it "preserves the verbatim value even on :other" do
        expect(finish_reason.value).to eq("supernova")
      end
    end

    context "when no table is given" do
      it "defaults to the Chat Completions vocabulary" do
        expect(described_class.deserialize("tool_calls").reason).to eq(:tool_call)
      end
    end
  end

  describe "predicates" do
    it { expect(described_class.new(reason: :stop, value: "stop")).to be_stop }
    it { expect(described_class.new(reason: :length, value: "MAX_TOKENS")).to be_length }
    it { expect(described_class.new(reason: :tool_call, value: "tool_use")).to be_tool_call }
    it { expect(described_class.new(reason: :filter, value: "RECITATION")).to be_filter }
    it { expect(described_class.new(reason: :other, value: "weird")).to be_other }
    it { expect(described_class.new(reason: :stop, value: "stop")).not_to be_filter }
  end

  describe "CHAT_COMPLETIONS table" do
    it "maps the Chat Completions vocabulary" do
      expect(described_class::CHAT_COMPLETIONS).to eq({
        "stop" => :stop,
        "length" => :length,
        "tool_calls" => :tool_call,
        "function_call" => :tool_call,
        "content_filter" => :filter,
      })
    end
  end
end
