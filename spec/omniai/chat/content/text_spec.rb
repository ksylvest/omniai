# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Content::Text do
  subject(:text) { described_class.new('Hello!') }

  describe '#text' do
    it { expect(text.text).to eq('Hello!') }
  end
end
