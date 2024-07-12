# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Response::DeltaChoice do
  subject(:choice) { described_class.new(data:) }

  let(:data) { { 'index' => 0, 'delta' => { 'role' => 'user', 'content' => 'Hello!' } } }

  it { expect(choice.index).to eq(0) }
  it { expect(choice.delta).not_to be_nil }
  it { expect(choice.delta.role).to eq('user') }
  it { expect(choice.delta.content).to eq('Hello!') }

  describe '#inspect' do
    let(:delta) { OmniAI::Chat::Response::Delta.new(data: data['delta']) }

    it { expect(choice.inspect).to eq(%(#<OmniAI::Chat::Response::DeltaChoice index=0 delta=#{delta.inspect}>)) }
  end

  describe '#part' do
    it { expect(choice.part).to be_a(OmniAI::Chat::Response::Delta) }
  end
end
