# frozen_string_literal: true

RSpec.describe OmniAI::Transcribe::Transcription do
  subject(:transcription) { build(:transcribe_transcription) }

  describe ".parse" do
    subject(:parse) { described_class.parse(data:, model:, format:) }

    context "with text data" do
      let(:data) { "Hi!" }
      let(:model) { "whisper" }
      let(:format) { "text" }

      it { expect(parse.text).to eq("Hi!") }
      it { expect(parse.model).to eq("whisper") }
      it { expect(parse.format).to eq("text") }
      it { expect(parse.duration).to be_nil }
      it { expect(parse.language).to be_nil }
      it { expect(parse.segments).to be_nil }
    end

    context "with hash data" do
      let(:data) do
        {
          "text" => "Hi!",
          "duration" => 5.0,
          "segments" => [],
          "language" => "en",
        }
      end
      let(:model) { "whisper" }
      let(:format) { "verbose_json" }

      it { expect(parse.text).to eq("Hi!") }
      it { expect(parse.model).to eq("whisper") }
      it { expect(parse.format).to eq("verbose_json") }
      it { expect(parse.duration).to eq(5.0) }
      it { expect(parse.language).to eq("en") }
      it { expect(parse.segments).to eq([]) }
    end
  end

  describe "#text" do
    it { expect(transcription.text).to eq("Hi!") }
  end

  describe "#model" do
    it { expect(transcription.model).to eq("whisper") }
  end

  describe "#format" do
    it { expect(transcription.format).to eq("text") }
  end

  describe "#inspect" do
    subject(:inspect) { transcription.inspect }

    it { expect(inspect).to eq('#<OmniAI::Transcribe::Transcription text="Hi!" model="whisper" format="text">') }
  end
end
