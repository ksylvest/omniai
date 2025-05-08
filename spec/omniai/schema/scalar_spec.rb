# frozen_string_literal: true

RSpec.describe OmniAI::Schema::Scalar do
  subject(:property) { build(:schema_scalar) }

  describe "#serialize" do
    subject(:serialize) { property.serialize }

    context "with a string" do
      let(:property) { build(:schema_scalar, :string, description: 'The unit (e.g. "F" or "C")', enum: %w[F C]) }

      it "converts the property to a hash" do
        expect(serialize).to eq({ type: "string", description: 'The unit (e.g. "F" or "C")', enum: %w[F C] })
      end
    end

    context "with an integer" do
      let(:property) { build(:schema_scalar, :integer) }

      it "converts the property to a hash" do
        expect(serialize).to eq({ type: "integer" })
      end
    end

    context "with a boolean" do
      let(:property) { build(:schema_scalar, :boolean) }

      it "converts the property to a hash" do
        expect(serialize).to eq({ type: "boolean" })
      end
    end

    context "with a number" do
      let(:property) { build(:schema_scalar, :number) }

      it "converts the property to a hash" do
        expect(serialize).to eq({ type: "number" })
      end
    end
  end

  describe "#parse" do
    context "when the type is boolean" do
      subject(:property) { build(:schema_scalar, :boolean) }

      it "parses the value as a boolean" do
        expect(property.parse(true)).to be_truthy
        expect(property.parse(false)).to be_falsey
      end
    end

    context "when the type is integer" do
      subject(:property) { build(:schema_scalar, :integer) }

      it "parses the value as an integer" do
        expect(property.parse(0)).to eq(0)
        expect(property.parse("0")).to eq(0)
      end
    end

    context "when the type is string" do
      subject(:property) { build(:schema_scalar, :string) }

      it "parses the value as a string" do
        expect(property.parse("fahrenheit")).to eq("fahrenheit")
      end
    end

    context "when the type is number" do
      subject(:property) { build(:schema_scalar, :number) }

      it "parses the value as a number" do
        expect(property.parse(0.0)).to eq(0.0)
      end
    end
  end
end
