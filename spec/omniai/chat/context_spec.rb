# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Context do
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
end
