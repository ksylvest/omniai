# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Usage do
  subject(:usage) { described_class.new(data:) }

  let(:data) { { 'input_tokens' => 2, 'output_tokens' => 3, 'total_tokens' => 5 } }

  context 'with input_tokens / output_tokens' do
    let(:data) do
      {
        'input_tokens' => 2,
        'output_tokens' => 3,
      }
    end

    it { expect(usage.input_tokens).to eq(2) }
    it { expect(usage.output_tokens).to eq(3) }
    it { expect(usage.total_tokens).to eq(5) }
  end

  context 'with prompt_tokens / completion_tokens / total_tokens' do
    let(:data) do
      {
        'prompt_tokens' => 2,
        'completion_tokens' => 3,
        'total_tokens' => 5,
      }
    end

    it { expect(usage.input_tokens).to eq(2) }
    it { expect(usage.output_tokens).to eq(3) }
    it { expect(usage.total_tokens).to eq(5) }
  end

  describe '#inspect' do
    it { expect(usage.inspect).to eq('#<OmniAI::Chat::Usage input_tokens=2 output_tokens=3 total_tokens=5>') }
  end
end
