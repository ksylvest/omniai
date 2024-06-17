# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Choice do
  subject(:choice) { described_class.new(data:) }

  describe '.for' do
    subject(:choice) { described_class.for(data:) }

    context 'with delta' do
      let(:data) { { 'index' => 0, 'delta' => { 'role' => 'user', 'content' => 'Hello!' } } }

      it { expect(choice.index).to eq(0) }
      it { expect(choice.delta).not_to be_nil }
      it { expect(choice.delta.role).to eq('user') }
      it { expect(choice.delta.content).to eq('Hello!') }
    end

    context 'with message' do
      let(:data) { { 'index' => 0, 'message' => { 'role' => 'user', 'content' => 'Hello!' } } }

      it { expect(choice.index).to eq(0) }
      it { expect(choice.message).not_to be_nil }
      it { expect(choice.message.role).to eq('user') }
      it { expect(choice.message.content).to eq('Hello!') }
    end
  end
end
