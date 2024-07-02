# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Response::Message do
  subject(:message) { described_class.new(role: 'user', content: 'Hello?') }

  describe '.for' do
    subject(:message) { described_class.for(data: { 'role' => 'user', 'content' => 'Hello?' }) }

    it { expect(message.role).to eq('user') }
    it { expect(message.content).to eq('Hello?') }
  end

  describe '#role' do
    it { expect(message.role).to eq('user') }
  end

  describe '#content' do
    it { expect(message.content).to eq('Hello?') }
  end

  describe '#inspect' do
    it {
      expect(message.inspect).to eq('#<OmniAI::Chat::Response::Message role="user" content="Hello?">')
    }
  end
end
