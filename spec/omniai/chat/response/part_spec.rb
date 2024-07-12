# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Response::Part do
  subject(:part) { described_class.new(data: { 'role' => 'system', 'content' => 'Hello!' }) }

  describe '#role' do
    it { expect(part.role).to eq('system') }
  end

  describe '#content' do
    it { expect(part.content).to eq('Hello!') }
  end
end
