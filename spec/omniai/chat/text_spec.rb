# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Text do
  subject(:text) { build(:chat_text, text: 'Hello!') }

  describe '#text' do
    it { expect(text.text).to eq('Hello!') }
  end

  describe '#inspect' do
    it { expect(text.inspect).to eql('#<OmniAI::Chat::Text text="Hello!">') }
  end

  describe '.deserialize' do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) { { 'text' => 'Hello!', 'type' => 'text' } }

    context 'with a deserializer' do
      let(:context) do
        OmniAI::Context.build do |context|
          context.deserializers[:text] = ->(data, *) { described_class.new(data['text']) }
        end
      end

      it { expect(deserialize).to be_a(described_class) }
      it { expect(deserialize.text).to eq('Hello!') }
    end

    context 'without a serializer' do
      let(:context) { OmniAI::Context.build }

      it { expect(deserialize).to be_a(described_class) }
      it { expect(deserialize.text).to eq('Hello!') }
    end
  end

  describe '#serialize' do
    subject(:serialize) { text.serialize(context:) }

    context 'with a serializer' do
      let(:context) do
        OmniAI::Context.build do |context|
          context.serializers[:text] = ->(text, *) { { type: 'text', text: text.text } }
        end
      end

      it { expect(serialize).to eq(type: 'text', text: 'Hello!') }
    end

    context 'without a serializer' do
      let(:context) { OmniAI::Context.build }

      it { expect(serialize).to eq(type: 'text', text: 'Hello!') }
    end
  end
end
