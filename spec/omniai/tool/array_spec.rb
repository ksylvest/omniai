# frozen_string_literal: true

RSpec.describe OmniAI::Tool::Array do
  subject(:array) { build(:tool_array) }

  it { expect(array.items).to be_a(OmniAI::Tool::Object) }
  it { expect(array.min_items).to be(2) }
  it { expect(array.max_items).to be(3) }

  describe '#serialize' do
    subject(:serialize) { array.serialize }

    it 'returns a hash' do
      expect(serialize).to eql({
        type: 'array',
        items: {
          type: 'object',
          description: 'A person.',
          properties: {
            name: { type: 'string', description: 'The name of the person.' },
            age: { type: 'integer', description: 'The age of the person.' },
            employeed: { type: 'boolean', description: 'Is the person employeed?' },
          },
          required: %i[name],
        },
        minItems: 2,
        maxItems: 3,
      })
    end
  end

  describe '#parse' do
    subject(:parse) do
      array.parse([
        { 'name' => 'Ringo', 'age' => '50', 'employeed' => true },
        { 'name' => 'George', 'age' => '25', 'employeed' => false },
      ])
    end

    it 'parses a hash' do
      expect(parse).to eql([
        { name: 'Ringo', age: 50, employeed: true },
        { name: 'George', age: 25, employeed: false },
      ])
    end
  end
end
