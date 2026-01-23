# frozen_string_literal: true

RSpec.describe OmniAI::Chat::ToolCallResult do
  subject(:tool_call_message) { build(:tool_call_result, content:, tool_call_id:) }

  let(:content) { "Hello!" }
  let(:tool_call_id) { "fake_id" }

  describe "#inspect" do
    subject(:inspect) { tool_call_message.inspect }

    it { expect(inspect).to eql('#<OmniAI::Chat::ToolCallResult content="Hello!" tool_call_id="fake_id">') }
  end

  describe "#options" do
    context "without extra kwargs" do
      it { expect(tool_call_message.options).to eq({}) }
    end

    context "with extra kwargs" do
      subject(:tool_call_message) { described_class.new(content:, tool_call_id:, thought_signature: "abc123") }

      it { expect(tool_call_message.options).to eq({ thought_signature: "abc123" }) }
    end
  end

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) { { "content" => "Hello!", "tool_call_id" => "fake_id" } }

    context "with a deserializer" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.deserializers[:tool_call_result] = lambda do |data, *|
            content = data["content"]
            tool_call_id = data["tool_call_id"]
            described_class.new(content:, tool_call_id:)
          end
        end
      end

      it { expect(deserialize).to be_a(described_class) }
      it { expect(deserialize.content).to eql("Hello!") }
      it { expect(deserialize.tool_call_id).to eql("fake_id") }
    end

    context "without a deserializer" do
      let(:context) { OmniAI::Context.build }

      it { expect(deserialize).to be_a(described_class) }
      it { expect(deserialize.content).to eql("Hello!") }
      it { expect(deserialize.tool_call_id).to eql("fake_id") }
    end
  end

  describe "#serialize" do
    subject(:serialize) { tool_call_message.serialize(context:) }

    context "with a serializer" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.serializers[:tool_call_result] = lambda do |tool_call_result, *|
            {
              content: tool_call_result.text,
              tool_call_id: tool_call_result.tool_call_id,
            }
          end
        end
      end

      it do
        expect(serialize).to eql({
          content: "Hello!",
          tool_call_id: "fake_id",
        })
      end
    end

    context "without a serializer" do
      let(:context) { OmniAI::Context.build }

      it do
        expect(serialize).to eql({
          content: "Hello!",
          tool_call_id: "fake_id",
        })
      end
    end
  end
end
