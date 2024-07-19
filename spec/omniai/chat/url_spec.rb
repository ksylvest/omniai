# frozen_string_literal: true

RSpec.describe OmniAI::Chat::URL do
  subject(:url) { described_class.new(uri, type) }

  let(:type) { 'image/png' }
  let(:uri) { 'https://localhost/hamster.png' }

  describe '#inspect' do
    it { expect(url.inspect).to eql('#<OmniAI::Chat::URL uri="https://localhost/hamster.png">') }
  end

  describe '#filename' do
    it { expect(url.filename).to eql('hamster.png') }
  end

  describe '#summarize' do
    it { expect(url.summarize).to eql('[hamster.png]') }
  end

  describe '#fetch!' do
    before do
      stub_request(:get, 'https://localhost/hamster.png')
        .to_return(body: 'Hello!', status: 200)
    end

    it { expect(url.fetch!).to eql('Hello!') }
  end

  describe '#data' do
    before do
      stub_request(:get, 'https://localhost/hamster.png')
        .to_return(body: 'Hello!', status: 200)
    end

    it { expect(url.data).to eq('SGVsbG8h') }
  end

  describe '#data_uri' do
    before do
      stub_request(:get, 'https://localhost/hamster.png')
        .to_return(body: 'Hello!', status: 200)
    end

    it { expect(url.data_uri).to eq('data:image/png;base64,SGVsbG8h') }
  end

  describe '.deserialize' do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) { { 'type' => 'image_url', 'image_url' => { 'url' => 'https://localhost/hamster.png' } } }

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
      it { expect(deserialize.uri).to eq('https://localhost/hamster.png') }
      it { expect(deserialize.type).to eq('image') }
    end

    context 'without a serializer' do
      let(:context) { OmniAI::Chat::Context.build }

      it { expect(deserialize).to be_a(described_class) }
      it { expect(deserialize.uri).to eq('https://localhost/hamster.png') }
      it { expect(deserialize.type).to eq('image') }
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

      it { expect(serialize).to eq(type: 'uri', uri: 'https://localhost/hamster.png') }
    end

    context 'without a serializer' do
      let(:context) { OmniAI::Chat::Context.build }

      context 'when serializing non-text' do
        it { expect(serialize).to eq(type: 'image_url', image_url: { url: 'https://localhost/hamster.png' }) }
      end

      context 'when serializing text' do
        let(:type) { 'text/plain' }
        let(:uri) { 'https://localhost/demo.txt' }

        before do
          stub_request(:get, 'https://localhost/demo.txt')
            .to_return(body: 'Hello!', status: 200)
        end

        it { expect(serialize).to eql({ type: 'text', text: '<file>demo.txt: Hello!</file>' }) }
      end
    end
  end
end
