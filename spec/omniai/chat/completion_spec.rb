# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Completion do
  subject(:completion) { described_class.new(data:) }

  let(:data) do
    {
      'id' => 'fake_id',
      'model' => 'fake_model',
      'created' => 0,
      'updated' => 0,
      'choices' => [],
      'usage' => {
        'input_tokens' => 0,
        'output_tokens' => 0,
        'total_tokens' => 0,
      },
    }
  end

  describe '#id' do
    it { expect(completion.id).to eq('fake_id') }
  end

  describe '#model' do
    it { expect(completion.model).to eq('fake_model') }
  end

  describe '#created' do
    it { expect(completion.created).to be_a(Time) }
  end

  describe '#updated' do
    it { expect(completion.updated).to be_a(Time) }
  end

  describe '#usage' do
    it { expect(completion.usage).to be_a(OmniAI::Chat::Response::Usage) }
  end

  describe '#choices' do
    it { expect(completion.choices).to be_empty }
  end

  describe '#inspect' do
    it { expect(completion.inspect).to eql('#<OmniAI::Chat::Completion id="fake_id" choices=[]') }
  end
end
