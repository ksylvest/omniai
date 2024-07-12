# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Response::Choice do
  subject(:choice) { described_class.new(data:) }

  let(:data) { { 'index' => 0 } }

  describe '#index' do
    it { expect(choice.index).to eq(0) }
  end
end
