# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Usage do
  subject(:usage) { build(:chat_usage, input_tokens: 2, output_tokens: 3, total_tokens: 5) }

  describe "#input_tokens" do
    it { expect(usage.input_tokens).to eq(2) }
  end

  describe "#output_tokens" do
    it { expect(usage.output_tokens).to eq(3) }
  end

  describe "#total_tokens" do
    it { expect(usage.total_tokens).to eq(5) }
  end

  describe "#thinking_tokens" do
    context "when the provider reports no breakdown" do
      it "is nil rather than zero" do
        expect(usage.thinking_tokens).to be_nil
      end
    end

    context "when the provider reports zero" do
      subject(:usage) { build(:chat_usage, thinking_tokens: 0) }

      it "is distinguishable from an absent breakdown" do
        expect(usage.thinking_tokens).to eq(0)
      end
    end

    context "when the provider reports a breakdown" do
      subject(:usage) { build(:chat_usage, input_tokens: 2, output_tokens: 9, thinking_tokens: 6) }

      it "is a subset of the output tokens, never an addition to them" do
        expect(usage.thinking_tokens).to be <= usage.output_tokens
      end
    end
  end

  describe "#inspect" do
    it { expect(usage.inspect).to eq("#<OmniAI::Chat::Usage input_tokens=2 output_tokens=3 total_tokens=5>") }

    context "with thinking tokens" do
      subject(:usage) { build(:chat_usage, input_tokens: 2, output_tokens: 9, total_tokens: 11, thinking_tokens: 6) }

      it {
        expect(usage.inspect)
          .to eq("#<OmniAI::Chat::Usage input_tokens=2 output_tokens=9 total_tokens=11 thinking_tokens=6>")
      }
    end
  end

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) { { "input_tokens" => 2, "output_tokens" => 3, "total_tokens" => 5 } }

    context "with a deserializer" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.deserializers[:usage] = lambda { |data, *|
            input_tokens = data["input_tokens"]
            output_tokens = data["output_tokens"]
            total_tokens = data["total_tokens"]
            described_class.new(input_tokens:, output_tokens:, total_tokens:)
          }
        end
      end

      it { expect(deserialize).to be_a(described_class) }
      it { expect(deserialize.input_tokens).to eq(2) }
      it { expect(deserialize.output_tokens).to eq(3) }
      it { expect(deserialize.total_tokens).to eq(5) }
    end

    context "without a deserializer" do
      let(:context) { OmniAI::Context.build }

      it { expect(deserialize).to be_a(described_class) }
      it { expect(deserialize.input_tokens).to eq(2) }
      it { expect(deserialize.output_tokens).to eq(3) }
      it { expect(deserialize.total_tokens).to eq(5) }
      it { expect(deserialize.thinking_tokens).to be_nil }
    end

    context "with its own thinking_tokens key" do
      let(:context) { OmniAI::Context.build }
      let(:data) { { "input_tokens" => 2, "output_tokens" => 9, "thinking_tokens" => 6 } }

      it "round-trips the field this class serializes" do
        expect(deserialize.thinking_tokens).to eq(6)
      end
    end

    context "with provider-specific breakdown vocabulary" do
      # Base reads only its own key and the flat OpenAI-compatible aliases. Nested vendor shapes are read by that
      # provider gem's own :usage deserializer, so base must not pick them up.
      let(:context) { OmniAI::Context.build }
      let(:data) do
        {
          "input_tokens" => 2,
          "output_tokens" => 9,
          "output_tokens_details" => { "thinking_tokens" => 6 },
        }
      end

      it "does not read it" do
        expect(deserialize.thinking_tokens).to be_nil
      end
    end
  end

  describe "#serialize" do
    subject(:serialize) { usage.serialize(context:) }

    context "with a serializer" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.serializers[:usage] = lambda do |usage, *|
            {
              input_tokens: usage.input_tokens,
              output_tokens: usage.output_tokens,
              total_tokens: usage.total_tokens,
            }
          end
        end
      end

      it { is_expected.to eq(input_tokens: 2, output_tokens: 3, total_tokens: 5) }
    end

    context "without a serializer" do
      let(:context) { OmniAI::Context.build }

      it { is_expected.to eq(input_tokens: 2, output_tokens: 3, total_tokens: 5) }
    end

    context "with thinking tokens" do
      let(:usage) { build(:chat_usage, input_tokens: 2, output_tokens: 9, total_tokens: 11, thinking_tokens: 6) }
      let(:context) { OmniAI::Context.build }

      it { is_expected.to eq(input_tokens: 2, output_tokens: 9, total_tokens: 11, thinking_tokens: 6) }

      it "round-trips" do
        expect(described_class.deserialize(serialize.transform_keys(&:to_s)).thinking_tokens).to eq(6)
      end
    end
  end
end
