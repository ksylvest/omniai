# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Function do
  subject(:function) { build(:chat_function, name:, arguments:) }

  let(:name) { "temperature" }
  let(:arguments) { { "unit" => "celsius" } }

  it { expect(function.name).to eq("temperature") }
  it { expect(function.arguments).to eq({ "unit" => "celsius" }) }

  describe "#inspect" do
    subject(:inspect) { function.inspect }

    it do
      expect(inspect)
        .to eq "#<OmniAI::Chat::Function name=\"temperature\" arguments=#{{ 'unit' => 'celsius' }.inspect}>"
    end
  end

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) { { "name" => "temperature", "arguments" => '{"unit": "celsius"}' } }

    context "with a deserializer" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.deserializers[:function] = lambda { |data, *|
            name = data["name"]
            arguments = JSON.parse(data["arguments"])
            described_class.new(name:, arguments:)
          }
        end
      end

      it { expect(deserialize).to be_a(described_class) }
      it { expect(deserialize.name).to eq("temperature") }
      it { expect(deserialize.arguments).to eq({ "unit" => "celsius" }) }
    end

    context "without a serializer" do
      let(:context) { OmniAI::Context.build }

      it { expect(deserialize).to be_a(described_class) }
      it { expect(deserialize.name).to eq("temperature") }
      it { expect(deserialize.arguments).to eq({ "unit" => "celsius" }) }
    end
  end

  describe "#serialize" do
    subject(:serialize) { function.serialize(context:) }

    context "with a serializer" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.serializers[:function] = lambda do |function, *|
            {
              name: function.name,
              arguments: JSON.generate(function.arguments),
            }
          end
        end
      end

      it { expect(serialize).to eq(name: "temperature", arguments: '{"unit":"celsius"}') }
    end

    context "without a serializer" do
      let(:context) { OmniAI::Context.build }

      it { expect(serialize).to eq(name: "temperature", arguments: '{"unit":"celsius"}') }
    end
  end
end
