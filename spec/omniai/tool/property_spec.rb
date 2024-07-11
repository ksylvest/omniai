# frozen_string_literal: true

RSpec.describe OmniAI::Tool::Property do
  subject(:property) { described_class.new(type:, description:, enum:) }

  let(:type) { described_class::Type::STRING }
  let(:description) { 'The unit (e.g. "fahrenheit" or "celsius")' }
  let(:enum) { %w[fahrenheit celsius] }

  describe '.boolean' do
    subject(:property) { described_class.boolean }

    it { expect(property.type).to eq('boolean') }
  end

  describe '.integer' do
    subject(:property) { described_class.integer }

    it { expect(property.type).to eq('integer') }
  end

  describe '.string' do
    subject(:property) { described_class.string }

    it { expect(property.type).to eq('string') }
  end

  describe '.number' do
    subject(:property) { described_class.number }

    it { expect(property.type).to eq('number') }
  end

  describe '#prepare' do
    it 'converts the property to a hash' do
      expect(property.prepare).to eq({
        type: 'string',
        description: 'The unit (e.g. "fahrenheit" or "celsius")',
        enum: %w[fahrenheit celsius],
      })
    end
  end

  describe '#parse' do
    context 'when the type is boolean' do
      let(:type) { described_class::Type::BOOLEAN }

      it 'parses the value as a boolean' do
        expect(property.parse(true)).to be_truthy
        expect(property.parse(false)).to be_falsey
      end
    end

    context 'when the type is integer' do
      let(:type) { described_class::Type::INTEGER }

      it 'parses the value as an integer' do
        expect(property.parse(0)).to eq(0)
        expect(property.parse('0')).to eq(0)
      end
    end

    context 'when the type is string' do
      let(:type) { described_class::Type::STRING }

      it 'parses the value as a string' do
        expect(property.parse('fahrenheit')).to eq('fahrenheit')
      end
    end

    context 'when the type is number' do
      let(:type) { described_class::Type::NUMBER }

      it 'parses the value as a number' do
        expect(property.parse(0.0)).to eq(0.0)
      end
    end
  end
end
