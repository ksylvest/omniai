# frozen_string_literal: true

RSpec.describe OmniAI::Google::Client do
  subject(:client) { described_class.new(**options) }

  let(:options) { {} }

  describe "#chat" do
    it "proxies" do
      allow(OmniAI::Google::Chat).to receive(:process!)
      client.chat("Hello!")
      expect(OmniAI::Google::Chat).to have_received(:process!)
    end
  end

  describe "#embed" do
    it "proxies" do
      allow(OmniAI::Google::Embed).to receive(:process!)
      client.embed("Hello!")
      expect(OmniAI::Google::Embed).to have_received(:process!)
    end
  end

  describe "#upload" do
    let(:io) { StringIO.new("Hello!") }

    it "proxies" do
      allow(OmniAI::Google::Upload).to receive(:process!)
      client.upload(io)
      expect(OmniAI::Google::Upload).to have_received(:process!)
    end
  end

  describe "#path" do
    context "without options" do
      it "returns the path" do
        expect(client.path).to eq("/#{client.version}")
      end
    end

    context "with options" do
      let(:options) { { project_id: "manhattan", location_id: "us-east4" } }

      it "returns the path" do
        expect(client.path).to eq("/#{client.version}/projects/manhattan/locations/us-east4/publishers/google")
      end
    end
  end

  describe "#connection" do
    context "without options" do
      it "returns an HTTP client" do
        expect(client.connection).to be_a(HTTP::Client)
      end
    end

    context "with options" do
      let(:options) { { credentials: } }
      let(:credentials) { instance_double(Google::Auth::ServiceAccountCredentials) }

      it "returns an HTTP client" do
        allow(credentials).to receive(:fetch_access_token!)
        allow(credentials).to receive(:access_token) { SecureRandom.alphanumeric }
        expect(client.connection).to be_a(HTTP::Client)
        expect(credentials).to have_received(:fetch_access_token!)
        expect(credentials).to have_received(:access_token)
      end
    end
  end
end
