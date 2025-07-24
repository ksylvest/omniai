# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Thread::Attachment do
  subject(:attachment) { described_class.new(data:, client:) }

  let(:client) { OmniAI::OpenAI::Client.new }

  let(:data) do
    {
      "file_id" => "file-123",
      "tools" => [{ "type" => "file_search" }],
    }
  end

  describe ".for" do
    context "with enumerable data" do
      it { expect(described_class.for(data: [data], client:)).to be_a(Array) }
    end

    context "without enumerable data" do
      it { expect(described_class.for(data: "Hello!", client:)).to eql("Hello!") }
    end
  end

  describe "#file_id" do
    it { expect(attachment.file_id).to eql("file-123") }
  end

  describe "#tools" do
    it { expect(attachment.tools).to eql([{ "type" => "file_search" }]) }
  end

  describe "#file!" do
    subject(:file!) { attachment.file! }

    before do
      stub_request(:get, "https://api.openai.com/v1/files/file-123")
        .to_return_json(body: {
          id: "file-123",
          filename: "file.txt",
          purpose: "assistants",
          bytes: 1024,
        })
    end

    it { expect(file!).to be_a(OmniAI::OpenAI::File) }
    it { expect(file!.id).to eql("file-123") }
    it { expect(file!.filename).to eql("file.txt") }
    it { expect(file!.purpose).to eql("assistants") }
    it { expect(file!.bytes).to be(1024) }
  end
end
