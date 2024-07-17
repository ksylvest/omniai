# frozen_string_literal: true

RSpec.describe OmniAI::Chat::File do
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

  describe '#inspect' do
    it { expect(file.inspect).to eql("#<OmniAI::Chat::File io=#{io.inspect}>") }
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

  describe '#serialize' do
    subject(:serialize) { file.serialize(context:) }

    context 'with a serializer' do
      let(:context) do
        OmniAI::Chat::Context.build do |context|
          context.serializers[:file] = ->(file, *) { { type: 'text_url', text_url: { url: file.data_uri } } }
        end
      end

      it { expect(serialize).to eql(type: 'text_url', text_url: { url: 'data:text/plain;base64,SGVsbG8h' }) }
    end

    context 'without a serializer' do
      let(:context) { OmniAI::Chat::Context.build }

      it { expect(serialize).to eql(type: 'text_url', text_url: { url: 'data:text/plain;base64,SGVsbG8h' }) }
    end
  end
end
