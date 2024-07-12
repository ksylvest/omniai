# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Response::Choice do
  subject(:choice) { described_class.new(data:) }

  let(:data) { { 'index' => 0 } }

  describe '#index' do
    it { expect(choice.index).to eq(0) }
  end

  describe '#part' do
    it { expect { choice.part }.to raise_error(NotImplementedError) }
  end

  describe '#tool_call_list' do
    it { expect { choice.tool_call_list }.to raise_error(NotImplementedError) }
  end
end
