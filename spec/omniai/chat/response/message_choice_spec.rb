# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Response::MessageChoice do
  subject(:choice) { described_class.new(index:, message:) }

  let(:index) { 0 }
  let(:message) { OmniAI::Chat::Response::Message.new(role: 'user', content: 'Hello!') }

  describe '.for' do
    subject(:choice) { described_class.for(data:) }

    let(:data) { { 'index' => 0, 'message' => { 'role' => 'user', 'content' => 'Hello!' } } }

    it { expect(choice.index).to eq(0) }
    it { expect(choice.message).not_to be_nil }
    it { expect(choice.message.role).to eq('user') }
    it { expect(choice.message.content).to eq('Hello!') }
  end

  describe '#inspect' do
    it { expect(choice.inspect).to eq("#<OmniAI::Chat::Response::MessageChoice index=0 message=#{message.inspect}>") }
  end
end
