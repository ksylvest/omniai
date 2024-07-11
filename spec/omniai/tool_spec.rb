# frozen_string_literal: true

RSpec.describe OmniAI::Tool do
  subject(:tool) { described_class.new(fibonacci, name:, description:, parameters:) }

  let(:fibonacci) do
    proc do |n:|
      next(0) if n == 0
      next(1) if n == 1

      fibonacci.call(n: n - 1) + fibonacci.call(n: n - 2)
    end
  end

  let(:name) { 'Fibonacci' }
  let(:description) { 'Calculate the nth Fibonacci' }

  let(:parameters) do
    OmniAI::Tool::Parameters.new(properties: {
      n: OmniAI::Tool::Property.integer(description: 'The nth Fibonacci number to calculate'),
    }, required: %i[n])
  end

  describe '#prepare' do
    it 'converts the tool to a hash' do
      expect(tool.prepare).to eq({
        type: 'function',
        function: {
          name:,
          description:,
          parameters: {
            type: 'object',
            properties: {
              n: { type: 'integer', description: 'The nth Fibonacci number to calculate' },
            },
            required: %i[n],
          },
        },
      })
    end
  end

  describe '#call' do
    it 'calls the proc' do
      expect(tool.call({ 'n' => 0 })).to eq(0)
      expect(tool.call({ 'n' => 1 })).to eq(1)
      expect(tool.call({ 'n' => 2 })).to eq(1)
      expect(tool.call({ 'n' => 3 })).to eq(2)
      expect(tool.call({ 'n' => 4 })).to eq(3)
      expect(tool.call({ 'n' => 5 })).to eq(5)
      expect(tool.call({ 'n' => 6 })).to eq(8)
    end
  end
end
