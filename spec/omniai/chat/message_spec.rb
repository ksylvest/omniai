# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Message do
  subject(:message) { described_class.new(data:) }

  let(:data) { { 'role' => 'user', 'content' => 'What is the capital of Japan?' } }

  describe '#role' do
    it { expect(message.role).to eq('user') }
  end

  describe '#content' do
    it { expect(message.content).to eq('What is the capital of Japan?') }
  end

  describe '#inspect' do
    it { expect(message.inspect).to eq('#<OmniAI::Chat::Message role="user" content="What is the capital of Japan?">') }
  end
end
