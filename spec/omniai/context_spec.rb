# frozen_string_literal: true

RSpec.describe OmniAI::Context do
  subject(:context) { described_class.new }

  describe '.build' do
    subject(:build) { described_class.build }

    it { expect(build).to be_a(described_class) }
  end

  describe '#serializers' do
    subject(:serializers) { context.serializers }

    it { expect(serializers).to be_a(Hash) }
  end

  describe '#deserializers' do
    subject(:deserializes) { context.deserializers }

    it { expect(deserializes).to be_a(Hash) }
  end

  describe '#serializer' do
    subject(:serializer) { context.serializer(name) }

    let(:name) { :example }

    context 'without a serializer' do
      it { expect(serializer).to be_nil }
    end

    context 'with a serializer' do
      before { context.serializers[:example] = example }

      let(:example) { -> {} }

      it { expect(serializer).to eql(example) }
    end
  end

  describe '#deserializer' do
    subject(:deserializer) { context.deserializer(name) }

    let(:name) { :example }

    context 'without a deserializer' do
      it { expect(deserializer).to be_nil }
    end

    context 'with a deserializer' do
      before { context.deserializers[:example] = example }

      let(:example) { -> {} }

      it { expect(deserializer).to eql(example) }
    end
  end
end
