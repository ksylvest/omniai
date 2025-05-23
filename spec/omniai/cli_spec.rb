# frozen_string_literal: true

RSpec.describe OmniAI::CLI do
  subject(:cli) { described_class.new(stdin:, stdout:, provider:) }

  let(:stdin) { StringIO.new(text) }
  let(:stdout) { StringIO.new }
  let(:provider) { "fake" }

  let(:client) { instance_double(OmniAI::Client) }

  let(:text) do
    <<~TEXT
      What is the capital of Canada?
      exit
    TEXT
  end

  describe "#parse" do
    context "with a chat command" do
      it "forwards the command to OmniAI::CLI::ChatHandler" do
        allow(OmniAI::CLI::ChatHandler).to receive(:handle!)
        cli.parse(["chat", "What is the capital of Canada?"])
        expect(OmniAI::CLI::ChatHandler).to have_received(:handle!)
          .with(stdin:, stdout:, provider:, argv: ["What is the capital of Canada?"])
      end
    end

    context "with a embed command" do
      it "forwards the command to OmniAI::CLI::EmbedHandler" do
        allow(OmniAI::CLI::EmbedHandler).to receive(:handle!)
        cli.parse(["embed", "What is the capital of Canada?"])
        expect(OmniAI::CLI::EmbedHandler).to have_received(:handle!)
          .with(stdin:, stdout:, provider:, argv: ["What is the capital of Canada?"])
      end
    end

    context "with a transcribe command" do
      it "forwards the command to OmniAI::CLI::TranscribeHandler" do
        allow(OmniAI::CLI::TranscribeHandler).to receive(:handle!)
        cli.parse(["transcribe", "./audio.wav"])
        expect(OmniAI::CLI::TranscribeHandler).to have_received(:handle!)
          .with(stdin:, stdout:, provider:, argv: ["./audio.wav"])
      end
    end

    context "with a speak command" do
      it "forwards the command to OmniAI::CLI::SpeakHandler" do
        allow(OmniAI::CLI::SpeakHandler).to receive(:handle!)
        cli.parse(["speak", "Sally sells sea shells by the sea shore."])
        expect(OmniAI::CLI::SpeakHandler).to have_received(:handle!)
          .with(stdin:, stdout:, provider:, argv: ["Sally sells sea shells by the sea shore."])
      end
    end

    context "with an unknown command" do
      it "raises an error" do
        expect { cli.parse(["unknown"]) }.to raise_error(OmniAI::Error, 'unsupported command="unknown"')
      end
    end

    context "with a version flag" do
      %w[-v --version].each do |option|
        it "prints version with '#{option}'" do
          expect { cli.parse([option]) }.to raise_error(SystemExit)
          expect(stdout.string).to eql("#{OmniAI::VERSION}\n")
        end
      end
    end

    context "with a help flag" do
      %w[-h --help].each do |option|
        it "prints help with '#{option}'" do
          expect { cli.parse([option]) }.to raise_error(SystemExit)
          expect(stdout.string).not_to be_empty
        end
      end
    end
  end
end
