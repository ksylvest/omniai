# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Content do
  subject(:content) { build(:chat_content) }

  describe '.summarize' do
    subject(:summarize) { described_class.summarize(content) }

    context 'with a string' do
      let(:content) { 'Hello!' }

      it { expect(summarize).to eq('Hello!') }
    end

    context 'with a content' do
      let(:content) { OmniAI::Chat::Text.new('Hello!') }

      it { expect(summarize).to eq('Hello!') }
    end

    context 'with an array' do
      let(:content) { [OmniAI::Chat::Text.new('Hello!')] }

      it { expect(summarize).to eq('Hello!') }
    end
  end

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
