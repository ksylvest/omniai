# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Response::Delta do
  subject(:delta) { described_class.new(role: 'user', content: 'Hello!') }

  describe '.for' do
    subject(:delta) { described_class.for(data: { 'role' => 'user', 'content' => 'Hello!' }) }

    it { expect(delta.role).to eq('user') }
    it { expect(delta.content).to eq('Hello!') }
  end

  describe '#role' do
    it { expect(delta.role).to eq('user') }
  end

  describe '#content' do
    it { expect(delta.content).to eq('Hello!') }
  end

  describe '#inspect' do
    it { expect(delta.inspect).to eq('#<OmniAI::Chat::Response::Delta role="user" content="Hello!">') }
  end
end
