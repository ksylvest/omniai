# frozen_string_literal: true

RSpec.describe OmniAI::Chat::URL do
  subject(:url) { described_class.new('https://localhost/greeting.txt', 'text/plain') }

  describe '#url' do
    it { expect(url.inspect).to eql('#<OmniAI::Chat::URL uri="https://localhost/greeting.txt">') }
  end

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

  describe '.deserialize' do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) { { 'type' => 'text_url', 'text_url' => { 'url' => 'https://localhost/greeting.txt' } } }

    context 'with a deserializer' do
      let(:context) do
        OmniAI::Chat::Context.build do |context|
          context.deserializers[:url] = lambda { |data, *|
            type = /(?<type>\w+)_url/.match(data['type'])[:type]
            uri = data["#{type}_url"]['url']
            described_class.new(uri, type)
          }
        end
      end

      it { expect(deserialize).to be_a(described_class) }
      it { expect(deserialize.uri).to eq('https://localhost/greeting.txt') }
      it { expect(deserialize.type).to eq('text') }
    end

    context 'without a serializer' do
      let(:context) { OmniAI::Chat::Context.build }

      it { expect(deserialize).to be_a(described_class) }
      it { expect(deserialize.uri).to eq('https://localhost/greeting.txt') }
      it { expect(deserialize.type).to eq('text') }
    end
  end

  describe '#serialize' do
    subject(:serialize) { url.serialize(context:) }

    context 'with a serializer' do
      let(:context) do
        OmniAI::Chat::Context.build do |context|
          context.serializers[:url] = ->(url, *) { { type: 'uri', uri: url.uri } }
        end
      end

      it { expect(serialize).to eq(type: 'uri', uri: 'https://localhost/greeting.txt') }
    end

    context 'without a serializer' do
      let(:context) { OmniAI::Chat::Context.build }

      it { expect(serialize).to eq(type: 'text_url', text_url: { url: 'https://localhost/greeting.txt' }) }
    end
  end
end