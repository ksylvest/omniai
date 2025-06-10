# frozen_string_literal: true

RSpec.describe OmniAI::Transcribe::Transcription do
  subject(:transcription) { described_class.new(text: "Hi!", model: "whisper", format: "text") }

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
    context "with basic attributes" do
      it { expect(transcription.inspect).to eq('#<OmniAI::Transcribe::Transcription text="Hi!">') }
    end

    context "with verbose attributes" do
      subject(:transcription) do
        described_class.new(
          text: "Hi!",
          model: "whisper",
          format: "text",
          duration: 5.0,
          segments: [{ "start" => 0, "end" => 5, "text" => "Hi!" }],
          language: "english"
        )
      end

      it "includes verbose information" do
        expect(transcription.inspect).to include("duration=5.0")
      end
    end
  end
end
