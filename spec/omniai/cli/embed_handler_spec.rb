# frozen_string_literal: true

RSpec.describe OmniAI::CLI::EmbedHandler do
  let(:stdin) { StringIO.new }
  let(:stdout) { StringIO.new }
  let(:provider) { "fake" }
  let(:model) { "fake" }

  describe ".handle!" do
    subject(:handle!) { described_class.handle!(argv:, stdin:, stdout:, provider:) }

    let(:client) { instance_double(OmniAI::Client) }

    context "when chatting" do
      let(:argv) do
        [
          "--model", model,
          "--provider", provider,
          prompt,
        ]
      end

      before do
        allow(OmniAI::Client).to receive(:find).with(provider:) { client }
        allow(client).to receive(:embed) { OmniAI::Embed::Response.new(data: { "data" => [{ "embedding" => [0.0] }] }) }
      end

      context "with a prompt" do
        let(:prompt) { "The quick brown fox jumps over a lazy dog." }

        it "runs calls chat" do
          handle!
          expect(stdout.string).to eql("0.0\n")
        end
      end

      context "without a prompt" do
        let(:prompt) { nil }

        let(:stdin) { StringIO.new("The quick brown fox jumps over a lazy dog.") }

        it "runs calls listen" do
          handle!
          expect(stdout.string).to include('Type "exit" or "quit" to leave.')
          expect(stdout.string).to include("0.0")
        end
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
