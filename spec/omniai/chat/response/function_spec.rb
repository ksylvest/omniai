# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Response::Function do
  subject(:function) { described_class.new(data:) }

  let(:data) { { 'name' => 'temperature', 'arguments' => '{ "unit": "celsius" }' } }

  it { expect(function.name).to eq('temperature') }
  it { expect(function.arguments).to eq({ 'unit' => 'celsius' }) }

  describe '#inspect' do
    subject(:inspect) { function.inspect }

    it { is_expected.to eq '#<OmniAI::Chat::Response::Function name="temperature" arguments={"unit"=>"celsius"}>' }
  end
end
