# frozen_string_literal: true

RSpec.describe OmniAI::Chat::ToolCall do
  subject(:tool_call) { build(:chat_tool_call, id:, function:) }

  let(:id) { "fake_tool_call_id" }
  let(:function) { build(:chat_function, name: "temperature", arguments: { "unit" => "celsius" }) }

  describe "#id" do
    it { expect(tool_call.id).to eq(id) }
  end

  describe "#function" do
    it { expect(tool_call.function).to eq(function) }
  end

  describe "#inspect" do
    subject(:inspect) { tool_call.inspect }

    it { is_expected.to eq(%(#<OmniAI::Chat::ToolCall id="fake_tool_call_id" function=#{function.inspect}>)) }
  end

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) do
      {
        "id" => "fake_tool_call_id",
        "function" => {
          "name" => "temperature",
          "arguments" => '{"unit":"celsius"}',
        },
      }
    end

    context "with a deserializer" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.deserializers[:tool_call] = lambda { |data, *|
            id = data["id"]
            function = OmniAI::Chat::Function.deserialize(data["function"])
            described_class.new(id:, function:)
          }
        end
      end

      it { expect(deserialize).to be_a(described_class) }
      it { expect(deserialize.id).to eq("fake_tool_call_id") }
      it { expect(deserialize.function).to be_a(OmniAI::Chat::Function) }
    end

    context "without a serializer" do
      let(:context) { OmniAI::Context.build }

      it { expect(deserialize).to be_a(described_class) }
      it { expect(deserialize.id).to eq("fake_tool_call_id") }
      it { expect(deserialize.function).to be_a(OmniAI::Chat::Function) }
    end
  end

  describe "#serialize" do
    subject(:serialize) { tool_call.serialize(context:) }

    context "with a serializer" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.serializers[:tool_call] = lambda do |tool_call, *|
            {
              id: tool_call.id,
              type: "function",
              function: tool_call.function.serialize(context:),
            }
          end
        end
      end

      it do
        expect(serialize).to eq(
          id: "fake_tool_call_id",
          type: "function",
          function: { name: "temperature", arguments: '{"unit":"celsius"}' }
        )
      end
    end

    context "without a serializer" do
      let(:context) { OmniAI::Context.build }

      it do
        expect(serialize).to eq(
          id: "fake_tool_call_id",
          type: "function",
          function: { name: "temperature", arguments: '{"unit":"celsius"}' }
        )
      end
    end
  end
end
