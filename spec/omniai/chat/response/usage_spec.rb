# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Response::Usage do
  subject(:usage) { described_class.new(input_tokens: 2, output_tokens: 3, total_tokens: 5) }

  describe '.for' do
    subject(:usage) { described_class.for(data:) }

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
  end

  describe '#input_tokens' do
    it { expect(usage.input_tokens).to eq(2) }
  end

  describe '#output_tokens' do
    it { expect(usage.output_tokens).to eq(3) }
  end

  describe '#prompt_tokens' do
    it { expect(usage.prompt_tokens).to eq(2) }
  end

  describe '#completion_tokens' do
    it { expect(usage.completion_tokens).to eq(3) }
  end

  describe '#total_tokens' do
    it { expect(usage.total_tokens).to eq(5) }
  end

  describe '#inspect' do
    it { expect(usage.inspect).to eq('#<OmniAI::Chat::Response::Usage input_tokens=2 output_tokens=3 total_tokens=5>') }
  end
end
