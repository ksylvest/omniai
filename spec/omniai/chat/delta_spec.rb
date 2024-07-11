# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Delta do
  subject(:delta) { described_class.new(data:) }

  let(:data) { { 'role' => 'user', 'content' => 'Hello!' } }

  describe '#role' do
    it { expect(delta.role).to eq('user') }
  end

  describe '#content' do
    it { expect(delta.content).to eq('Hello!') }
  end

  describe '#inspect' do
    it { expect(delta.inspect).to eq('#<OmniAI::Chat::Delta role="user" content="Hello!">') }
  end
end
