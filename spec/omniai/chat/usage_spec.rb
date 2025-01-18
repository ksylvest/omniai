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

  describe "#inspect" do
    it { expect(usage.inspect).to eq("#<OmniAI::Chat::Usage input_tokens=2 output_tokens=3 total_tokens=5>") }
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
  end
end
