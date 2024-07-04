# frozen_string_literal: true

RSpec.describe OmniAI::CLI::ChatHandler do
  let(:stdin) { StringIO.new }
  let(:stdout) { StringIO.new }
  let(:provider) { 'fake' }
  let(:model) { 'fake' }
  let(:temperature) { '0.7' }
  let(:format) { 'text' }

  describe '.handle!' do
    subject(:handle!) { described_class.handle!(argv:, stdin:, stdout:, provider:) }

    let(:client) { instance_double(OmniAI::Client) }

    context 'when chatting' do
      let(:argv) do
        [
          '--model', model,
          '--temperature', temperature,
          '--provider', provider,
          '--format', format,
          prompt,
        ]
      end

      before do
        allow(OmniAI::Client).to receive(:find).with(provider:) { client }
        allow(client).to receive(:chat) { stdout << 'Ottawa' }
      end

      context 'with a prompt' do
        let(:prompt) { 'What is the capital of Canada?' }

        it 'runs calls chat' do
          handle!
          expect(stdout.string).to eql('Ottawa')
        end
      end

      context 'without a prompt' do
        let(:prompt) { nil }

        let(:stdin) { StringIO.new("What is the capital of Canada?\n") }

        it 'runs calls listen' do
          handle!
          expect(stdout.string).to include('Type "exit" or "quit" to leave.')
          expect(stdout.string).to include('Ottawa')
        end
      end
    end

    context 'with a help flag' do
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
