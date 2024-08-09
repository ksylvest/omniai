# frozen_string_literal: true

RSpec.describe OmniAI::Embed::Usage do
  subject(:usage) { build(:embed_usage, prompt_tokens:, total_tokens:) }

  let(:prompt_tokens) { 2 }
  let(:total_tokens) { 4 }

  describe '#inspect' do
    it { expect(usage.inspect).to eql('#<OmniAI::Embed::Usage prompt_tokens=2 total_tokens=4>') }
  end

  describe '#prompt_tokens' do
    it { expect(usage.prompt_tokens).to be(2) }
  end

  describe '#total_tokens' do
    it { expect(usage.total_tokens).to be(4) }
  end
end
