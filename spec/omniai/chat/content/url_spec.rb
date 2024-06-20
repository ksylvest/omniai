# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Content::URL do
  subject(:url) { described_class.new('https://localhost/greeting.txt', 'text/plain') }

  describe '#fetch!' do
    before do
      stub_request(:get, 'https://localhost/greeting.txt')
        .to_return(body: 'Hello!', status: 200)
    end

    it { expect(url.fetch!).to eql('Hello!') }
  end

  describe '#data' do
    before do
      stub_request(:get, 'https://localhost/greeting.txt')
        .to_return(body: 'Hello!', status: 200)
    end

    it { expect(url.data).to eq('SGVsbG8h') }
  end

  describe '#data_uri' do
    before do
      stub_request(:get, 'https://localhost/greeting.txt')
        .to_return(body: 'Hello!', status: 200)
    end

    it { expect(url.data_uri).to eq('data:text/plain;base64,SGVsbG8h') }
  end
end
