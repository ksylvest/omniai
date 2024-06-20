# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Content::File do
  subject(:file) { described_class.new(io, type) }

  let(:io) do
    Tempfile.new.tap do |tempfile|
      tempfile.write('Hello!')
      tempfile.rewind
    end
  end

  let(:type) { 'text/plain' }

  around do |example|
    example.call
  ensure
    io.close
    io.unlink
  end

  describe '#type' do
    it { expect(file.type).to eq('text/plain') }
  end

  describe '#io' do
    it { expect(file.io).to eq(io) }
  end

  describe '#fetch!' do
    it { expect(file.fetch!).to eql('Hello!') }
  end

  describe '#data' do
    it { expect(file.data).to eq('SGVsbG8h') }
  end

  describe '#data_uri' do
    it { expect(file.data_uri).to eq('data:text/plain;base64,SGVsbG8h') }
  end
end
