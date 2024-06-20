# frozen_string_literal: true

RSpec.describe OmniAI::Chat::DeltaChoice do
  subject(:choice) { described_class.new(data:) }

  describe '.for' do
    subject(:choice) { described_class.for(data:) }

    let(:data) { { 'index' => 0, 'delta' => { 'role' => 'user', 'content' => 'Hello!' } } }

    it { expect(choice.index).to eq(0) }
    it { expect(choice.delta).not_to be_nil }
    it { expect(choice.delta.role).to eq('user') }
    it { expect(choice.delta.content).to eq('Hello!') }
  end
end
