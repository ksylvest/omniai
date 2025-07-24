# frozen_string_literal: true

RSpec.describe OmniAI::Google::Chat::FunctionSerializer do
  let(:context) { OmniAI::Google::Chat::CONTEXT }

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) do
      {
        "name" => "temperature",
        "args" => { "unit" => "celsius" },
      }
    end

    it { expect(deserialize).to be_a(OmniAI::Chat::Function) }
  end

  describe ".serialize" do
    subject(:serialize) { described_class.serialize(function, context:) }

    let(:function) { OmniAI::Chat::Function.new(name: "temperature", arguments: { unit: "celsius" }) }

    it { expect(serialize).to eql(name: "temperature", args: { unit: "celsius" }) }
  end
end
