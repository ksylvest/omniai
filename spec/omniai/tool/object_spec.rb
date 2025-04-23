# frozen_string_literal: true

RSpec.describe OmniAI::Tool::Object do
  subject(:object) { build(:tool_object) }

  it { expect(object.properties).to be_a(Hash) }
  it { expect(object.required).to be_a(Array) }
  it { expect(object.description).to be_a(String) }

  describe "#serialize" do
    subject(:serialize) { object.serialize }

    it "returns a hash" do
      expect(serialize).to eql({
        type: "object",
        description: "A person.",
        properties: {
          name: { type: "string", description: "The name of the person." },
          age: { type: "integer", description: "The age of the person." },
          employed: { type: "boolean", description: "Is the person employed?" },
        },
        required: %i[name],
      })
    end
  end

  describe "#parse" do
    subject(:parse) do
      object.parse({
        "name" => "Ringo",
        "age" => "50",
        "employed" => true,
      })
    end

    it "parses an object" do
      expect(parse).to eql({
        name: "Ringo",
        age: 50,
        employed: true,
      })
    end
  end
end
