# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Message do
  subject(:message) { build(:chat_message, role:, content:) }

  let(:role) { OmniAI::Chat::Role::USER }
  let(:content) { [] }

  describe ".build" do
    context "with text" do
      subject(:message) do
        described_class.build("What is the capital of Canada?", role: "user")
      end

      it "builds a message" do
        expect(message).to be_a(described_class)
      end
    end

    context "with block" do
      subject(:message) do
        described_class.build do |builder|
          builder.text("What is the capital of Canada?")
          builder.url("https://localhost/greeting.txt", "text/plain")
          builder.file("greeting.txt", "Hello!")
        end
      end

      it do
        expect(message).to be_a(described_class)
      end
    end
  end

  describe "#inspect" do
    it { expect(message.inspect).to eql('#<OmniAI::Chat::Message role="user" content=[]>') }
  end

  describe "#merge" do
    subject(:merge) { parent_message.merge(child_message) }

    let(:parent_message) { build(:chat_message, content: "ABC") }
    let(:child_message) { build(:chat_message, content: "DEF") }

    it { expect(merge).to be_a(described_class) }
    it { expect(merge.role).to eql("user") }
    it { expect(merge.content).to eql("ABCDEF") }
  end

  describe "#role" do
    it { expect(message.role).to eq("user") }
  end

  describe "#user?" do
    context "when role is user" do
      let(:role) { OmniAI::Chat::Role::USER }

      it { expect(message).to be_user }
    end

    context "when role is system" do
      let(:role) { OmniAI::Chat::Role::SYSTEM }

      it { expect(message).not_to be_user }
    end
  end

  describe "#system?" do
    context "when role is system" do
      let(:role) { OmniAI::Chat::Role::SYSTEM }

      it { expect(message).to be_system }
    end

    context "when role is user" do
      let(:role) { OmniAI::Chat::Role::USER }

      it { expect(message).not_to be_system }
    end
  end

  describe "#tool" do
    context "when role is tool" do
      let(:role) { OmniAI::Chat::Role::TOOL }

      it { expect(message).to be_tool }
    end

    context "when role is system" do
      let(:role) { OmniAI::Chat::Role::USER }

      it { expect(message).not_to be_tool }
    end
  end

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) { { "role" => "user", "content" => [{ "type" => "text", "text" => " Hello!" }] } }

    context "with a deserializer" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.deserializers[:message] = lambda do |data, *|
            role = data["role"]
            content = data["content"].map { |content_data| OmniAI::Chat::Content.deserialize(content_data, context:) }
            described_class.new(role:, content:)
          end
        end
      end

      it { expect(deserialize).to be_a(described_class) }
      it { expect(deserialize.role).to eq("user") }
      it { expect(deserialize.content).not_to be_empty }
      it { expect(deserialize.content).to all(be_a(OmniAI::Chat::Content)) }
    end

    context "without a serializer" do
      let(:context) { OmniAI::Context.build }

      it { expect(deserialize).to be_a(described_class) }
      it { expect(deserialize.role).to eq("user") }
      it { expect(deserialize.content).not_to be_empty }
      it { expect(deserialize.content).to all(be_a(OmniAI::Chat::Content)) }
    end
  end

  describe "#serialize" do
    subject(:serialize) { message.serialize(context:) }

    context "with a serializer" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.serializers[:message] = lambda do |message, *|
            {
              role: message.role,
              content: message.content.is_a?(String) ? message.content : message.content.map(&:serialize),
            }
          end
        end
      end

      context "with text content" do
        let(:content) { "What is the capital of Canada?" }

        it do
          expect(serialize).to eql({
            role: "user",
            content: "What is the capital of Canada?",
          })
        end
      end

      context "with array content" do
        let(:io) { Tempfile.new }
        let(:content) do
          [
            OmniAI::Chat::Text.new("What are these photos of?"),
            OmniAI::Chat::URL.new("https://localhost/cat.jpeg", "image/jpeg"),
            OmniAI::Chat::URL.new("https://localhost/dog.jpeg", "image/jpeg"),
            OmniAI::Chat::File.new(io, "image/jpeg"),
          ]
        end

        it do
          expect(serialize).to eql({
            role: "user",
            content: [
              { type: "text", text: "What are these photos of?" },
              { type: "image_url", image_url: { url: "https://localhost/cat.jpeg" } },
              { type: "image_url", image_url: { url: "https://localhost/dog.jpeg" } },
              { type: "image_url", image_url: { url: "data:image/jpeg;base64," } },
            ],
          })
        end
      end
    end

    context "without a serializer" do
      let(:context) { OmniAI::Context.build }

      context "with text content" do
        let(:content) { "What is the capital of Canada?" }

        it do
          expect(serialize).to eql({
            role: "user",
            content: "What is the capital of Canada?",
          })
        end
      end

      context "with array content" do
        let(:io) { Tempfile.new }
        let(:content) do
          [
            OmniAI::Chat::Text.new("What are these photos of?"),
            OmniAI::Chat::URL.new("https://localhost/cat.jpeg", "image/jpeg"),
            OmniAI::Chat::URL.new("https://localhost/dog.jpeg", "image/jpeg"),
            OmniAI::Chat::File.new(io, "image/jpeg"),
          ]
        end

        it do
          expect(serialize).to eql({
            role: "user",
            content: [
              { type: "text", text: "What are these photos of?" },
              { type: "image_url", image_url: { url: "https://localhost/cat.jpeg" } },
              { type: "image_url", image_url: { url: "https://localhost/dog.jpeg" } },
              { type: "image_url", image_url: { url: "data:image/jpeg;base64," } },
            ],
          })
        end
      end
    end
  end
end
