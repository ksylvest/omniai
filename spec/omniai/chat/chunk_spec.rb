# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Chunk do
  subject(:chunk) { described_class.new(data:) }

  let(:data) do
    {
      'id' => 'fake_id',
      'model' => 'fake_model',
      'created' => 0,
      'updated' => 0,
      'choices' => [],
    }
  end

  describe '#id' do
    it { expect(chunk.id).to eq('fake_id') }
  end

  describe '#model' do
    it { expect(chunk.model).to eq('fake_model') }
  end

  describe '#created' do
    it { expect(chunk.created).to be_a(Time) }
  end

  describe '#updated' do
    it { expect(chunk.updated).to be_a(Time) }
  end

  describe '#choices' do
    it { expect(chunk.choices).to be_empty }
  end
end
