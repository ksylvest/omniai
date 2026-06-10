# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Choice do
  subject(:choice) { build(:chat_choice, message:, index: 0) }

  let(:message) { build(:chat_message, role: "user", content: "Hello!") }

  describe "#inspect" do
    it { expect(choice.inspect).to eq(%(#<OmniAI::Chat::Choice index=0 message=#{message.inspect}>)) }
  end

  describe "#index" do
    it { expect(choice.index).to eq(0) }
  end

  describe "#message" do
    it { expect(choice.message).to eql(message) }
  end

  describe "#finish_reason" do
    context "when set" do
      subject(:choice) { build(:chat_choice, message:, index: 0, finish_reason:) }

      let(:finish_reason) { OmniAI::Chat::FinishReason.new(reason: :stop, value: "stop") }

      it { expect(choice.finish_reason).to eql(finish_reason) }
    end

    context "when unset" do
      it { expect(choice.finish_reason).to be_nil }
    end
  end

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) { { "index" => 0, "message" => { "role" => "user", "content" => "Hello!" } } }

    context "with a known finish_reason in the data (base / OpenAI-compatible path)" do
      let(:context) { OmniAI::Context.build }
      let(:data) do
        { "index" => 0, "message" => { "role" => "user", "content" => "Hello!" }, "finish_reason" => "length" }
      end

      it "normalizes the reason" do
        expect(deserialize.finish_reason.reason).to eq(:length)
      end

      it "preserves the verbatim value" do
        expect(deserialize.finish_reason.value).to eq("length")
      end
    end

    context "with an unrecognized finish_reason in the data" do
      let(:context) { OmniAI::Context.build }
      let(:data) do
        { "index" => 0, "message" => { "role" => "user", "content" => "Hello!" }, "finish_reason" => "supernova" }
      end

      it "maps the reason to :other but preserves the verbatim value" do
        expect(deserialize.finish_reason).to be_other
        expect(deserialize.finish_reason.value).to eq("supernova")
      end
    end

    context "with no finish_reason in the data" do
      let(:context) { OmniAI::Context.build }

      it "leaves it nil (absence is not :other)" do
        expect(deserialize.finish_reason).to be_nil
      end
    end

    context "with a deserializer" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.deserializers[:choice] = lambda { |data, *|
            index = data["index"]
            message = OmniAI::Chat::Message.deserialize(data["message"], context:)
            described_class.new(message:, index:)
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
    subject(:serialize) { choice.serialize(context:) }

    context "with a serializer" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.serializers[:choice] = lambda do |choice, *|
            {
              index: choice.index,
              message: choice.message.serialize(context:),
            }
          end
        end
      end

      it { expect(serialize).to eq({ index: 0, message: { role: "user", content: "Hello!" } }) }
    end

    context "without a serializer" do
      let(:context) { OmniAI::Context.build }

      it { expect(serialize).to eq({ index: 0, message: { role: "user", content: "Hello!" } }) }
    end
  end
end
