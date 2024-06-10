# frozen_string_literal: true

RSpec.describe OmniAI::Chat do
  subject(:chat) { described_class.new(client:) }

  let(:client) { instance_double(OmniAI::Client) }
  let(:api_key) { '...' }

  describe '#completion' do
    subject(:completion) { chat.completion(prompt, model:, temperature: 0.7, format: :text) }

    let(:prompt) { 'Tell me a joke!' }
    let(:model) { '...' }

    it { expect { completion }.to raise_error(NotImplementedError) }
  end
end
