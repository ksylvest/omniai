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

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) { { "index" => 0, "message" => { "role" => "user", "content" => "Hello!" } } }

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
