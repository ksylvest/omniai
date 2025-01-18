# frozen_string_literal: true

RSpec.describe OmniAI::Tool::Parameters do
  subject(:parameters) { described_class.new(properties:, required:) }

  let(:properties) do
    {
      n: OmniAI::Tool::Property.integer(description: "The nth number to calculate."),
    }
  end

  let(:required) { %i[n] }

  describe "#serialize" do
    it "converts the parameters to a hash" do
      expect(parameters.serialize).to eq({
        type: "object",
        properties: {
          n: { type: "integer", description: "The nth number to calculate." },
        },
        required: %i[n],
      })
    end
  end

  describe "#parse" do
    it "parses the arguments" do
      expect(parameters.parse({ "n" => 42 })).to eq({ n: 42 })
    end
  end
end
