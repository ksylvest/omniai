# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Response::DeltaChoice do
  subject(:choice) { described_class.new(index:, delta:) }

  let(:index) { 0 }
  let(:delta) { OmniAI::Chat::Response::Delta.new(role: 'user', content: 'Hello!') }

  describe '.for' do
    subject(:choice) { described_class.for(data:) }

    let(:data) { { 'index' => 0, 'delta' => { 'role' => 'user', 'content' => 'Hello!' } } }

    it { expect(choice.index).to eq(0) }
    it { expect(choice.delta).not_to be_nil }
    it { expect(choice.delta.role).to eq('user') }
    it { expect(choice.delta.content).to eq('Hello!') }
  end

  describe '#inspect' do
    it { expect(choice.inspect).to eq("#<OmniAI::Chat::Response::DeltaChoice index=0 delta=#{delta.inspect}>") }
  end
end
