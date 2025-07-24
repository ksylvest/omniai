# frozen_string_literal: true

RSpec.describe OmniAI::Google::Upload do
  let(:client) { OmniAI::Google::Client.new }

  describe ".process!" do
    subject(:process!) { described_class.process!(client:, io:) }

    before do
      stub_request(:post, "https://generativelanguage.googleapis.com/upload/#{client.version}/files?key=#{client.api_key}")
        .to_return_json(body: {
          file: {
            name: "files/greeting",
            mimeType: "text/plain",
            uri: "https://generativelanguage.googleapis.com/#{client.version}/files/greeting",
            state: "ACTIVE",
          },
        })
    end

    context "with a file" do
      let(:io) { Pathname.new(File.dirname(__FILE__)).join("..", "..", "fixtures", "greeting.txt").open }

      it { expect(process!).to be_a(OmniAI::Google::Upload::File) }
      it { expect(process!.name).to eql("files/greeting") }
      it { expect(process!.mime_type).to eql("text/plain") }
      it { expect(process!.uri).to eql("https://generativelanguage.googleapis.com/#{client.version}/files/greeting") }
      it { expect(process!.state).to eql("ACTIVE") }
    end

    context "with a URL" do
      let(:io) { "https://localhost/greeting.txt" }

      before do
        stub_request(:get, "https://localhost/greeting.txt")
          .to_return(body: "Greetings!")
      end

      it { expect(process!).to be_a(OmniAI::Google::Upload::File) }
      it { expect(process!.name).to eql("files/greeting") }
      it { expect(process!.mime_type).to eql("text/plain") }
      it { expect(process!.uri).to eql("https://generativelanguage.googleapis.com/#{client.version}/files/greeting") }
      it { expect(process!.state).to eql("ACTIVE") }
    end
  end
end
