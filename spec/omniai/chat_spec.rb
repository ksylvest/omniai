# frozen_string_literal: true

class FakeClient < OmniAI::Client
  def connection
    HTTP.persistent('http://localhost:8080')
  end
end

class FakeChat < OmniAI::Chat
  module Model
    FAKE = 'fake'
  end

  def path
    '/chat'
  end

  def payload
    { messages:, model: @model }
  end
end

RSpec.describe OmniAI::Chat do
  subject(:chat) { described_class.new(messages, model:, client:) }

  let(:model) { '...' }
  let(:client) { OmniAI::Client.new(api_key: '...') }
  let(:messages) do
    [
      { role: described_class::Role::SYSTEM, content: 'You are a helpful assistant.' },
      'What is the name of the dummer for the Beatles?',
    ]
  end

  describe '#path' do
    it { expect { chat.send(:path) }.to raise_error(NotImplementedError) }
  end

  describe '#payload' do
    it { expect { chat.send(:payload) }.to raise_error(NotImplementedError) }
  end

  describe '.process!' do
    subject(:process!) { FakeChat.process!(messages, model:, client:, stream:) }

    let(:stream) { nil }
    let(:client) { FakeClient.new(api_key: '...') }
    let(:model) { FakeChat::Model::FAKE }

    context 'when OK' do
      before do
        stub_request(:post, 'http://localhost:8080/chat')
          .with(body: {
            messages: [
              { role: 'system', content: 'You are a helpful assistant.' },
              { role: 'user', content: 'What is the name of the dummer for the Beatles?' },
            ],
            model:,
          })
          .to_return_json(status: 200, body: {
            choices: [{
              index: 0,
              message: {
                role: 'system',
                content: '{ "name": "Ringo" }',
              },
            }],
          })
      end

      it { expect(process!).to be_a(OmniAI::Chat::Completion) }
    end

    context 'when UNPROCESSABLE' do
      before do
        stub_request(:post, 'http://localhost:8080/chat')
          .with(body: {
            messages: [
              { role: 'system', content: 'You are a helpful assistant.' },
              { role: 'user', content: 'What is the name of the dummer for the Beatles?' },
            ],
            model:,
          })
          .to_return(status: 422, body: 'An unknown error occurred.')
      end

      it { expect { process! }.to raise_error(OmniAI::HTTPError) }
    end

    context 'when OK with stream' do
      let(:stream) { proc { |chunk| } }

      before do
        stub_request(:post, 'http://localhost:8080/chat')
          .with(body: {
            messages: [
              { role: 'system', content: 'You are a helpful assistant.' },
              { role: 'user', content: 'What is the name of the dummer for the Beatles?' },
            ],
            model:,
          })
          .to_return(status: 200, body: <<~STREAM)
            data: #{JSON.generate({ choices: [{ delta: { role: 'system', content: 'A' } }] })}\n
            data: #{JSON.generate({ choices: [{ delta: { role: 'system', content: 'B' } }] })}\n
            data: [DONE]\n
          STREAM
      end

      it do
        chunks = []
        allow(stream).to receive(:call) { |chunk| chunks << chunk }
        process!
        expect(chunks.map { |chunk| chunk.choice.delta.content }).to eql(%w[A B])
      end
    end

    context 'when UNPROCESSABLE with stream' do
      let(:stream) { proc { |chunk| } }

      before do
        stub_request(:post, 'http://localhost:8080/chat')
          .with(body: {
            messages: [
              { role: 'system', content: 'You are a helpful assistant.' },
              { role: 'user', content: 'What is the name of the dummer for the Beatles?' },
            ],
            model:,
          })
          .to_return(status: 422, body: 'An unknown error occurred.')
      end

      it { expect { process! }.to raise_error(OmniAI::HTTPError) }
    end
  end
end
