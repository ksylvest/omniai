# frozen_string_literal: true

RSpec.describe OmniAI::Chat::File do
  subject(:file) { build(:chat_file, io:, type:) }

  let(:io) do
    Tempfile.new.tap do |tempfile|
      tempfile.write('Hello!')
      tempfile.rewind
    end
  end

  let(:type) { 'image/png' }

  around do |example|
    example.call
  ensure
    io.close
    io.unlink
  end

  describe '#type' do
    it { expect(file.type).to eq('image/png') }
  end

  describe '#io' do
    it { expect(file.io).to eq(io) }
  end

  describe '#inspect' do
    it { expect(file.inspect).to eql("#<OmniAI::Chat::File io=#{io.inspect}>") }
  end

  describe '#filename' do
    it { expect(file.filename).to eql(File.basename(io)) }
  end

  describe '#summarize' do
    it { expect(file.summarize).to eql("[#{file.filename}]") }
  end

  describe '#fetch!' do
    it { expect(file.fetch!).to eql('Hello!') }
  end

  describe '#data' do
    it { expect(file.data).to eq('SGVsbG8h') }
  end

  describe '#data_uri' do
    it { expect(file.data_uri).to eq('data:image/png;base64,SGVsbG8h') }
  end

  describe '#serialize' do
    subject(:serialize) { file.serialize(context:) }

    context 'with a serializer' do
      let(:context) do
        OmniAI::Context.build do |context|
          context.serializers[:file] = ->(file, *) { { type: 'image_url', image_url: { url: file.data_uri } } }
        end
      end

      it { expect(serialize).to eql(type: 'image_url', image_url: { url: 'data:image/png;base64,SGVsbG8h' }) }
    end

    context 'without a serializer' do
      let(:context) { OmniAI::Context.build }

      context 'when serializing non-text' do
        it { expect(serialize).to eql(type: 'image_url', image_url: { url: 'data:image/png;base64,SGVsbG8h' }) }
      end

      context 'when serializing text' do
        let(:type) { 'text/plain' }

        it { expect(serialize).to eql({ type: 'text', text: "<file>#{File.basename(io)}: Hello!</file>" }) }
      end
    end
  end
end
