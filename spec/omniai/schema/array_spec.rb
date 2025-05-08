# frozen_string_literal: true

RSpec.describe OmniAI::Schema::Array do
  subject(:array) { build(:schema_array) }

  it { expect(array.items).to be_a(OmniAI::Schema::Object) }
  it { expect(array.min_items).to be(2) }
  it { expect(array.max_items).to be(3) }

  describe "#serialize" do
    subject(:serialize) { array.serialize }

    it "returns a hash" do
      expect(serialize).to eql({
        type: "array",
        items: {
          type: "object",
          description: "A person.",
          properties: {
            name: { type: "string", description: "The name of the person." },
            age: { type: "integer", description: "The age of the person." },
            employed: { type: "boolean", description: "Is the person employed?" },
          },
          required: %i[name],
        },
        minItems: 2,
        maxItems: 3,
      })
    end
  end

  describe "#parse" do
    subject(:parse) do
      array.parse([
        { "name" => "Ringo", "age" => "50", "employed" => true },
        { "name" => "George", "age" => "25", "employed" => false },
      ])
    end

    it "parses a hash" do
      expect(parse).to eql([
        { name: "Ringo", age: 50, employed: true },
        { name: "George", age: 25, employed: false },
      ])
    end
  end
end
