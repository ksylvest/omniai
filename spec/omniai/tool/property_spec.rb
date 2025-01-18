# frozen_string_literal: true

RSpec.describe OmniAI::Tool::Property do
  subject(:property) { build(:tool_property) }

  describe ".array" do
    subject(:array) do
      described_class.array(items:, min_items:, max_items:)
    end

    let(:min_items) { 2 }
    let(:max_items) { 3 }
    let(:items) { build(:tool_property, :string, description: "A string.") }

    it { expect(array).to be_a(OmniAI::Tool::Array) }
    it { expect(array.items).to eql(items) }
    it { expect(array.min_items).to eql(min_items) }
    it { expect(array.max_items).to eql(max_items) }
  end

  describe ".object" do
    subject(:object) { described_class.object(properties:, required:) }

    let(:properties) do
      {
        name: build(:tool_property, :string, description: "The name of the person."),
        age: build(:tool_property, :integer, description: "The age of the person."),
      }
    end

    let(:required) { %i[name] }

    it { expect(object).to be_a(OmniAI::Tool::Object) }
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

  describe "#serialize" do
    subject(:serialize) { property.serialize }

    context "with a string" do
      let(:property) { build(:tool_property, :string, description: 'The unit (e.g. "F" or "C")', enum: %w[F C]) }

      it "converts the property to a hash" do
        expect(serialize).to eq({ type: "string", description: 'The unit (e.g. "F" or "C")', enum: %w[F C] })
      end
    end

    context "with an integer" do
      let(:property) { build(:tool_property, :integer) }

      it "converts the property to a hash" do
        expect(serialize).to eq({ type: "integer" })
      end
    end

    context "with a boolean" do
      let(:property) { build(:tool_property, :boolean) }

      it "converts the property to a hash" do
        expect(serialize).to eq({ type: "boolean" })
      end
    end

    context "with a number" do
      let(:property) { build(:tool_property, :number) }

      it "converts the property to a hash" do
        expect(serialize).to eq({ type: "number" })
      end
    end
  end

  describe "#parse" do
    context "when the type is boolean" do
      subject(:property) { build(:tool_property, :boolean) }

      it "parses the value as a boolean" do
        expect(property.parse(true)).to be_truthy
        expect(property.parse(false)).to be_falsey
      end
    end

    context "when the type is integer" do
      subject(:property) { build(:tool_property, :integer) }

      it "parses the value as an integer" do
        expect(property.parse(0)).to eq(0)
        expect(property.parse("0")).to eq(0)
      end
    end

    context "when the type is string" do
      subject(:property) { build(:tool_property, :string) }

      it "parses the value as a string" do
        expect(property.parse("fahrenheit")).to eq("fahrenheit")
      end
    end

    context "when the type is number" do
      subject(:property) { build(:tool_property, :number) }

      it "parses the value as a number" do
        expect(property.parse(0.0)).to eq(0.0)
      end
    end
  end
end
