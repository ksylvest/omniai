# frozen_string_literal: true

RSpec.describe OmniAI::Chat::MessageChoice do
  subject(:choice) { described_class.new(data:) }

  let(:data) { { 'index' => 0, 'message' => { 'role' => 'user', 'content' => 'Hello!' } } }

  it { expect(choice.index).to eq(0) }
  it { expect(choice.message).not_to be_nil }
  it { expect(choice.message.role).to eq('user') }
  it { expect(choice.message.content).to eq('Hello!') }

  describe '#inspect' do
    let(:message) { OmniAI::Chat::Response::Message.new(data: data['message']) }

    it { expect(choice.inspect).to eq(%(#<OmniAI::Chat::MessageChoice index=0 message=#{message.inspect}>)) }
  end
end
