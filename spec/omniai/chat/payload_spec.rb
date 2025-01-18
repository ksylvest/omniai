# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Payload do
  subject(:payload) { build(:chat_payload, choices:, usage:) }

  let(:usage) { build(:chat_usage) }
  let(:choices) { [] }

  describe "#inspect" do
    it { expect(payload.inspect).to eql("#<OmniAI::Chat::Payload choices=#{choices.inspect} usage=#{usage.inspect}>") }
  end

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) do
      {
        "choices" => [],
        "usage" => {
          "input_tokens" => 0,
          "output_tokens" => 0,
          "total_tokens" => 0,
        },
      }
    end

    context "with a deserializer" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.deserializers[:payload] = lambda { |data, *|
            choices = data["choices"].map { Choice.deserialize(data, context:) }
            usage = OmniAI::Chat::Usage.deserialize(data["usage"], context:)
            described_class.new(choices:, usage:)
          }
        end
      end

      it { expect(deserialize).to be_a(described_class) }
    end

    context "without a serializer" do
      let(:context) { OmniAI::Context.build }

      it { expect(deserialize).to be_a(described_class) }
    end
  end

  describe "#serialize" do
    subject(:serialize) { payload.serialize(context:) }

    context "with a serializer" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.serializers[:payload] = lambda do |payload, *|
            {
              choices: payload.choices.map { |choice| choice.serialize(context:) },
              usage: payload.usage&.serialize(context:),
            }
          end
        end
      end

      it { expect(serialize).to eq(choices: [], usage: { input_tokens: 2, output_tokens: 3, total_tokens: 5 }) }
    end

    context "without a serializer" do
      let(:context) { OmniAI::Context.build }

      it { expect(serialize).to eq(choices: [], usage: { input_tokens: 2, output_tokens: 3, total_tokens: 5 }) }
    end
  end
end
