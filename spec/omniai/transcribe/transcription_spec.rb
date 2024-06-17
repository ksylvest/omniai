# frozen_string_literal: true

RSpec.describe OmniAI::Transcribe::Transcription do
  subject(:transcription) { described_class.new(format: OmniAI::Transcribe::Format::JSON, data: { 'text' => 'Hi!' }) }

  describe '#format' do
    it { expect(transcription.format).to eq('json') }
  end

  describe '#text' do
    it { expect(transcription.text).to eq('Hi!') }
  end

  describe '#inspect' do
    it { expect(transcription.inspect).to eq('#<OmniAI::Transcribe::Transcription text="Hi!" format="json">') }
  end
end
