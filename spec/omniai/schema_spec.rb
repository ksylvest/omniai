# frozen_string_literal: true

RSpec.describe OmniAI::Schema do
  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data) }

    let(:data) do
      {
        type: "object",
        description: "Contact",
        properties: {
          name: {
            type: "string",
          },
          relationship: {
            type: "string",
            enum: %w[friend family],
          },
          addresses: {
            type: "array",
            items: {
              type: "object",
              properties: {
                street: { type: "string" },
                city: { type: "string" },
                state: { type: "string" },
                zip: { type: "string" },
              },
              required: %i[street city state zip],
            },
          },
        },
        required: %i[name],
      }
    end

    it { expect(deserialize).to be_a(OmniAI::Schema::Object) }
    it { expect(deserialize.description).to eq("Contact") }
    it { expect(deserialize.required).to eq(%i[name]) }
    it { expect(deserialize.properties).to be_a(Hash) }
    it { expect(deserialize.properties[:name]).to be_a(OmniAI::Schema::Scalar) }
    it { expect(deserialize.properties[:relationship]).to be_a(OmniAI::Schema::Scalar) }
    it { expect(deserialize.properties[:addresses]).to be_a(OmniAI::Schema::Array) }
    it { expect(deserialize.properties[:addresses].items.required).to eq(%i[street city state zip]) }
    it { expect(deserialize.properties[:addresses].items).to be_a(OmniAI::Schema::Object) }
    it { expect(deserialize.properties[:addresses].items.properties).to be_a(Hash) }
    it { expect(deserialize.properties[:addresses].items.properties[:street]).to be_a(OmniAI::Schema::Scalar) }
    it { expect(deserialize.properties[:addresses].items.properties[:city]).to be_a(OmniAI::Schema::Scalar) }
    it { expect(deserialize.properties[:addresses].items.properties[:state]).to be_a(OmniAI::Schema::Scalar) }
    it { expect(deserialize.properties[:addresses].items.properties[:zip]).to be_a(OmniAI::Schema::Scalar) }
  end

  describe ".build" do
    subject(:property) { described_class.build(kind, **options) }

    context "when kind is ':array'" do
      let(:kind) { :array }
      let(:options) { { items: build(:schema_scalar, :string) } }

      it { expect(property).to be_a(OmniAI::Schema::Array) }
    end

    context "when kind is ':object'" do
      let(:kind) { :object }
      let(:options) { { properties: { name: build(:schema_scalar, :string) }, required: %i[name] } }

      it { expect(property).to be_a(OmniAI::Schema::Object) }
      it { expect(property.properties).to be_a(Hash) }
      it { expect(property.properties[:name]).to be_a(OmniAI::Schema::Scalar) }
      it { expect(property.required).to eql(%i[name]) }
    end

    context "when kind is ':boolean'" do
      let(:kind) { :boolean }
      let(:options) { { description: "Either true or false" } }

      it { expect(property).to be_a(OmniAI::Schema::Scalar) }
      it { expect(property.description).to eql("Either true or false") }
      it { expect(property.type).to eql("boolean") }
    end

    context "when kind is ':integer'" do
      let(:kind) { :integer }
      let(:options) { { description: "e.g. 1, 2, 3, ..." } }

      it { expect(property).to be_a(OmniAI::Schema::Scalar) }
      it { expect(property.description).to eql("e.g. 1, 2, 3, ...") }
      it { expect(property.type).to eql("integer") }
    end

    context "when kind is ':string'" do
      let(:kind) { :string }
      let(:options) { { description: "e.g. 'the quick brown fox...'" } }

      it { expect(property).to be_a(OmniAI::Schema::Scalar) }
      it { expect(property.description).to eql("e.g. 'the quick brown fox...'") }
      it { expect(property.type).to eql("string") }
    end

    context "when kind is ':number'" do
      let(:kind) { :number }
      let(:options) { { description: "e.g. 3.1415..." } }

      it { expect(property).to be_a(OmniAI::Schema::Scalar) }
      it { expect(property.description).to eql("e.g. 3.1415...") }
      it { expect(property.type).to eql("number") }
    end
  end

  describe ".array" do
    subject(:array) do
      described_class.array(items:, min_items:, max_items:)
    end

    let(:min_items) { 2 }
    let(:max_items) { 3 }
    let(:items) { build(:schema_scalar, :string, description: "A string.") }

    it { expect(array).to be_a(OmniAI::Schema::Array) }
    it { expect(array.items).to eql(items) }
    it { expect(array.min_items).to eql(min_items) }
    it { expect(array.max_items).to eql(max_items) }
  end

  describe ".object" do
    subject(:object) { described_class.object(properties:, required:) }

    let(:properties) do
      {
        name: build(:schema_scalar, :string, description: "The name of the person."),
        age: build(:schema_scalar, :integer, description: "The age of the person."),
      }
    end

    let(:required) { %i[name] }

    it { expect(object).to be_a(OmniAI::Schema::Object) }
    it { expect(object.properties).to eql(properties) }
    it { expect(object.required).to eql(required) }
  end

  describe ".boolean" do
    subject(:property) { described_class.boolean }

    it { expect(property.type).to eq("boolean") }
  end

  describe ".integer" do
    subject(:property) { described_class.integer }

    it { expect(property.type).to eq("integer") }
  end

  describe ".string" do
    subject(:property) { described_class.string }

    it { expect(property.type).to eq("string") }
  end

  describe ".number" do
    subject(:property) { described_class.number }

    it { expect(property.type).to eq("number") }
  end
end
