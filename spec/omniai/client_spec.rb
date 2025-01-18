# frozen_string_literal: true

RSpec.describe OmniAI::Client do
  subject(:client) { described_class.new(api_key:, host:, timeout:, logger:) }

  let(:api_key) { "abcdef" }
  let(:host) { "http://localhost:8080" }
  let(:timeout) { 5 }
  let(:logger) { instance_double(Logger) }

  describe ".anthropic" do
    subject(:anthropic) { described_class.anthropic }

    context "when the client is defined" do
      let(:klass) { Class.new }

      before { stub_const("OmniAI::Anthropic::Client", klass) }

      it { expect(anthropic).to eql(klass) }
    end

    context "when the client is not defined" do
      it { expect { anthropic }.to raise_error(OmniAI::Error) }
    end
  end

  describe ".google" do
    subject(:google) { described_class.google }

    context "when the client is defined" do
      let(:klass) { Class.new }

      before { stub_const("OmniAI::Google::Client", klass) }

      it { expect(google).to eql(klass) }
    end

    context "when the client is not defined" do
      it { expect { google }.to raise_error(OmniAI::Error) }
    end
  end

  describe ".mistral" do
    subject(:mistral) { described_class.mistral }

    context "when the client is defined" do
      let(:klass) { Class.new }

      before { stub_const("OmniAI::Mistral::Client", klass) }

      it { expect(mistral).to eql(klass) }
    end

    context "when the client is not defined" do
      it { expect { mistral }.to raise_error(OmniAI::Error) }
    end
  end

  describe ".openai" do
    subject(:openai) { described_class.openai }

    context "when the client is defined" do
      let(:klass) { Class.new }

      before { stub_const("OmniAI::OpenAI::Client", klass) }

      it { expect(openai).to eql(klass) }
    end

    context "when the client is not defined" do
      it { expect { openai }.to raise_error(OmniAI::Error) }
    end
  end

  describe ".find" do
    subject(:find) { described_class.find(provider:) }

    context 'when the provider is "anthropic"' do
      let(:provider) { "anthropic" }

      it "calls .anthropic" do
        allow(described_class).to receive(:anthropic) { Class.new }
        find
        expect(described_class).to have_received(:anthropic)
      end
    end

    context "when the provider is google" do
      let(:provider) { "google" }

      it "calls .google" do
        allow(described_class).to receive(:google) { Class.new }
        find
        expect(described_class).to have_received(:google)
      end
    end

    context "when the provider is mistral" do
      let(:provider) { "mistral" }

      it "calls .mistral" do
        allow(described_class).to receive(:mistral) { Class.new }
        find
        expect(described_class).to have_received(:mistral)
      end
    end

    context "when the provider is openai" do
      let(:provider) { "openai" }

      it "calls .openai" do
        allow(described_class).to receive(:openai) { Class.new }
        find
        expect(described_class).to have_received(:openai)
      end
    end

    context "with an unknown provider" do
      let(:provider) { "other" }

      it { expect { find }.to raise_error(OmniAI::Error, 'unknown provider="other"') }
    end
  end

  describe "#api_key" do
    it { expect(client.api_key).to eq(api_key) }
  end

  describe "#host" do
    it { expect(client.host).to eq(host) }
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
    it { expect(client.inspect).to eq('#<OmniAI::Client api_key="abc***" host="http://localhost:8080">') }
  end
end
