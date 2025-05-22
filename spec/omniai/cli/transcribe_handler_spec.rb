# frozen_string_literal: true

RSpec.describe OmniAI::CLI::TranscribeHandler do
  let(:stdin) { StringIO.new }
  let(:stdout) { StringIO.new }
  let(:provider) { "fake" }
  let(:model) { "fake" }
  let(:language) { OmniAI::Transcribe::Language::ENGLISH }
  let(:format) { OmniAI::Transcribe::Format::TEXT }

  describe ".handle!" do
    subject(:handle!) { described_class.handle!(argv:, stdin:, stdout:, provider:) }

    let(:client) { instance_double(OmniAI::Client) }
    let(:transcription) { build(:transcribe_transcription) }
    let(:path) { Pathname(File.dirname(__FILE__)).join("..", "..", "fixtures", "file.ogg") }

    context "when transcribing" do
      let(:argv) do
        [
          "--model", model,
          "--language", language,
          "--provider", provider,
          "--format", format,
          path,
        ]
      end

      before do
        allow(OmniAI).to receive(:client).with(provider:) { client }
        allow(client).to receive(:transcribe) { transcription }
      end

      it "transcribes" do
        handle!
        expect(stdout.string).to eql("#{transcription.text}\n")
      end
    end

    context "with a help flag" do
      %w[-h --help].each do |option|
        let(:argv) { [option] }

        it "prints help with '#{option}'" do
          expect { handle! }.to raise_error(SystemExit)
          expect(stdout.string).not_to be_empty
        end
      end
    end
  end
end
