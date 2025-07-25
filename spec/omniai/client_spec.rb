# frozen_string_literal: true

RSpec.describe OmniAI::Client do
  subject(:client) { build(:client, timeout:, logger:) }

  let(:timeout) { 5 }
  let(:logger) { instance_double(Logger) }

  describe ".find" do
    subject(:find) { described_class.find(provider:) }

    context 'when the provider is "anthropic"' do
      let(:provider) { "anthropic" }

      it "returns an instance of OmniAI::Anthropic::Client" do
        expect(find).to be_an_instance_of(OmniAI::Anthropic::Client)
      end
    end

    context 'when the provider is "deepseek"' do
      let(:provider) { "deepseek" }

      it "returns an instance of OmniAI::DeepSeek::Client" do
        expect(find).to be_an_instance_of(OmniAI::DeepSeek::Client)
      end
    end

    context "when the provider is google" do
      let(:provider) { "google" }

      it "returns an instance of OmniAI::Google::Client" do
        expect(find).to be_an_instance_of(OmniAI::Google::Client)
      end
    end

    context "when the provider is llama" do
      let(:provider) { "llama" }

      it "calls .llama" do
        expect(find).to be_an_instance_of(OmniAI::Llama::Client)
      end
    end

    context "when the provider is mistral" do
      let(:provider) { "mistral" }

      it "returns an instance of OmniAI::Mistral::Client" do
        expect(find).to be_an_instance_of(OmniAI::Mistral::Client)
      end
    end

    context "when the provider is openai" do
      let(:provider) { "openai" }

      it "returns an instance of OmniAI::OpenAI::Client" do
        expect(find).to be_an_instance_of(OmniAI::OpenAI::Client)
      end
    end

    context "with an unknown provider" do
      let(:provider) { "other" }

      it { expect { find }.to raise_error(OmniAI::Error, 'unknown provider="other"') }
    end
  end

  describe ".discover" do
    subject(:discover) { described_class.discover }

    context "when find returns a client" do
      let(:client) { instance_double(described_class) }

      it "returns a client" do
        allow(described_class).to receive(:find) { client }
        expect(discover).to eql(client)
        expect(described_class).to have_received(:find)
      end
    end

    context "when find does not return a client" do
      it "raises an error" do
        allow(described_class).to receive(:find).and_raise(OmniAI::LoadError)
        expect { discover }.to raise_error(OmniAI::LoadError)
        expect(described_class).to have_received(:find).exactly(5).times
      end
    end
  end

  describe "#timeout" do
    it { expect(client.timeout).to eq(timeout) }
  end

  describe "#logger" do
    it { expect(client.logger).to eq(logger) }
  end

  describe "#connection" do
    it { expect(client.connection).to be_a(HTTP::Client) }
  end

  describe "#chat" do
    it { expect { client.chat("Hello!", model: "...") }.to raise_error(NotImplementedError) }
  end

  describe "#embed" do
    it { expect { client.embed("Hello!", model: "...") }.to raise_error(NotImplementedError) }
  end

  describe "#inspect" do
    it { expect(client.inspect).to eq("#<OmniAI::Client>") }
  end
end
