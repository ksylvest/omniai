# frozen_string_literal: true

RSpec.describe OmniAI::Schema::Format do
  subject(:format) { build(:schema_format, name: "Contact") }

  it { expect(format.name).to be_a(String) }
  it { expect(format.schema).to be_a(OmniAI::Schema::Object) }

  describe "#serialize" do
    subject(:serialize) { format.serialize }

    it "returns a hash" do
      expect(serialize).to eql({
        name: "Contact",
        schema: format.schema.serialize,
      })
    end
  end

  describe ".deserialize" do
    subject(:deserialize) do
      described_class.deserialize({
        "name" => "Contact",
        "schema" => {
          "type" => "object",
          "properties" => {
            "name" => { "type" => "string" },
          },
          "required" => ["name"],
        },
      })
    end

    it "returns a format" do
      expect(deserialize).to be_a(described_class)
    end
  end

  describe "#parse" do
    subject(:parse) { format.parse(text) }

    let(:text) { JSON.generate(name: "Ringo Starr") }

    it "parses" do
      expect(parse).to eql({ name: "Ringo Starr" })
    end
  end
end
