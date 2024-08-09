# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Media do
  subject(:media) { build(:chat_media, type:) }

  let(:type) { 'text/plain' }

  describe '#type' do
    it { expect(media.type).to eq('text/plain') }
  end

  describe '#fetch!' do
    it { expect { media.fetch! }.to raise_error(NotImplementedError) }
  end

  describe '#text?' do
    context 'when type is text/plain' do
      let(:type) { 'text/plain' }

      it { expect(media).to be_text }
    end

    context 'when type is application/pdf' do
      let(:type) { 'application/pdf' }

      it { expect(media).not_to be_text }
    end
  end

  describe '#audio?' do
    context 'when type is audio/flac' do
      let(:type) { 'audio/flac' }

      it { expect(media).to be_audio }
    end

    context 'when type is application/pdf' do
      let(:type) { 'application/pdf' }

      it { expect(media).not_to be_audio }
    end
  end

  describe '#image?' do
    context 'when type is image/jpeg' do
      let(:type) { 'image/jpeg' }

      it { expect(media).to be_image }
    end

    context 'when type is application/pdf' do
      let(:type) { 'application/pdf' }

      it { expect(media).not_to be_image }
    end
  end

  describe '#video?' do
    context 'when type is video/mpeg' do
      let(:type) { 'video/mpeg' }

      it { expect(media).to be_video }
    end

    context 'when type is application/pdf' do
      let(:type) { 'application/pdf' }

      it { expect(media).not_to be_video }
    end
  end

  describe '#kind' do
    subject(:kind) { media.kind }

    context 'when type is audio/flac' do
      let(:type) { 'audio/flac' }

      it { expect(kind).to eq(:audio) }
    end

    context 'when type is image/jpeg' do
      let(:type) { 'image/jpeg' }

      it { expect(kind).to eq(:image) }
    end

    context 'when type is video/mpeg' do
      let(:type) { 'video/mpeg' }

      it { expect(kind).to eq(:video) }
    end

    context 'when type is text/plain' do
      let(:type) { 'text/plain' }

      it { expect(kind).to eq(:text) }
    end

    context 'when type is application/pdf' do
      let(:type) { 'application/pdf' }

      it { expect { kind }.to raise_error(described_class::TypeError, 'unsupported type=application/pdf') }
    end
  end
end
