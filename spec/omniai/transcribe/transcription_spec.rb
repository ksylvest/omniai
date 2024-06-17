# frozen_string_literal: true

RSpec.describe OmniAI::Transcribe::Transcription do
  subject(:transcription) { described_class.new(text: 'Hi!', model: 'whisper', format: 'text') }

  describe '#text' do
    it { expect(transcription.text).to eq('Hi!') }
  end

  describe '#model' do
    it { expect(transcription.model).to eq('whisper') }
  end

  describe '#format' do
    it { expect(transcription.format).to eq('text') }
  end

  describe '#inspect' do
    it { expect(transcription.inspect).to eq('#<OmniAI::Transcribe::Transcription text="Hi!">') }
  end
end
