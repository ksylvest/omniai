# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Response do
  subject(:response) { build(:chat_response, choices:, usage:) }

  let(:usage) { build(:chat_usage) }
  let(:choice) { build(:chat_choice, message:) }
  let(:message) { build(:chat_message, content: "Hello!") }
  let(:choices) { [choice] }

  describe "#inspect" do
    it {
      expect(response.inspect).to eql("#<OmniAI::Chat::Response choices=#{choices.inspect} usage=#{usage.inspect}>")
    }
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
          context.deserializers[:response] = lambda { |data, *|
            choices = data["choices"].map { Choice.deserialize(data, context:) }
            usage = OmniAI::Chat::Usage.deserialize(data["usage"], context:)
            described_class.new(data:, choices:, usage:)
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
    subject(:serialize) { response.serialize(context:) }

    context "with a serializer" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.serializers[:response] = lambda do |response, *|
            {
              choices: response.choices.map { |choice| choice.serialize(context:) },
              usage: response.usage&.serialize(context:),
            }
          end
        end
      end

      it { expect(serialize).to eq(choices: [choice.serialize(context:)], usage: usage.serialize(context:)) }
    end

    context "without a serializer" do
      let(:context) { OmniAI::Context.build }

      it { expect(serialize).to eq(choices: [choice.serialize(context:)], usage: usage.serialize(context:)) }
    end
  end

  describe "#usage" do
    it "returns the usage" do
      expect(response.usage).to be_a(OmniAI::Chat::Usage)
    end
  end

  describe "#choices" do
    it "returns the choices" do
      expect(response.choices).to all(be_a(OmniAI::Chat::Choice))
    end
  end

  describe "#messages" do
    it "returns the messages" do
      expect(response.messages).to all(be_a(OmniAI::Chat::Message))
    end
  end

  describe "#choice" do
    it "returns the choice" do
      expect(response.choice).to be_a(OmniAI::Chat::Choice)
    end
  end

  describe "#message" do
    it "returns the message" do
      expect(response.message).to be_a(OmniAI::Chat::Message)
    end
  end

  describe "#text" do
    it "returns the content" do
      expect(response.text).to eq("Hello!")
    end
  end
end
