# frozen_string_literal: true

RSpec.describe OmniAI::Client do
  subject(:client) { described_class.new(api_key:, host:, timeout:, logger:) }

  let(:api_key) { 'abcdef' }
  let(:host) { 'http://localhost:8080' }
  let(:timeout) { 5 }
  let(:logger) { instance_double(Logger) }

  describe '#api_key' do
    it { expect(client.api_key).to eq(api_key) }
  end

  describe '#host' do
    it { expect(client.host).to eq(host) }
  end

  describe '#timeout' do
    it { expect(client.timeout).to eq(timeout) }
  end

  describe '#logger' do
    it { expect(client.logger).to eq(logger) }
  end

  describe '#connection' do
    it { expect(client.connection).to be_a(HTTP::Client) }
  end

  describe '#chat' do
    it { expect { client.chat('Hello!', model: '...') }.to raise_error(NotImplementedError) }
  end

  describe '#inspect' do
    it { expect(client.inspect).to eq('#<OmniAI::Client api_key="abc***" host="http://localhost:8080">') }
  end
end
