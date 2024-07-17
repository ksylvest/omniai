# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Content do
  subject(:content) { described_class.new }

  describe '#serialize' do
    subject(:serialize) { content.serialize }

    it { expect { serialize }.to raise_error(NotImplementedError) }
  end

  describe '.deserialize' do
    subject(:deserialize) { described_class.deserialize(data) }

    context 'with text' do
      let(:data) { { 'type' => 'text', 'text' => 'Hello!' } }

      it { expect(deserialize).to be_a(OmniAI::Chat::Text) }
      it { expect(deserialize.text).to eq('Hello!') }
    end

    context 'with url' do
      let(:data) { { 'type' => 'text_url', 'text_url' => { 'url' => 'https://localhost/greeting.txt' } } }

      it { expect(deserialize).to be_a(OmniAI::Chat::URL) }
      it { expect(deserialize.uri).to eq('https://localhost/greeting.txt') }
    end

    context 'with other' do
      let(:data) { { 'type' => 'other' } }

      it { expect { deserialize }.to raise_error(ArgumentError) }
    end
  end
end
