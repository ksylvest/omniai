# frozen_string_literal: true

RSpec.describe OmniAI::CLI::SpeakHandler do
  let(:stdin) { StringIO.new }
  let(:stdout) { StringIO.new }
  let(:provider) { "fake" }
  let(:model) { "fake" }
  let(:voice) { "human" }
  let(:speed) { "2.0" }
  let(:format) { OmniAI::Speak::Format::AAC }

  let(:text) { "Sally sells sea shells by the sea shore." }

  describe ".handle!" do
    subject(:handle!) { described_class.handle!(argv:, stdin:, stdout:, provider:) }

    let(:client) { instance_double(OmniAI::Client) }

    context "when speaking" do
      let(:argv) do
        [
          "--model", model,
          "--voice", voice,
          "--provider", provider,
          "--format", format,
          "--speed", speed,
          text,
        ]
      end

      before do
        allow(OmniAI).to receive(:client).with(provider:) { client }
        allow(client).to receive(:speak).and_yield("DATA")
      end

      it "speaks" do
        handle!
        expect(stdout.string).to eql("DATA")
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
