# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Thread::Annotation do
  subject(:annotation) { described_class.new(data:, client:) }

  let(:client) { OmniAI::OpenAI::Client.new }

  let(:data) do
    {
      "type" => "file_citation",
      "text" => "[...]",
      "start_index" => 2,
      "end_index" => 4,
      "file_citation" => { "file_id" => "file-123" },
    }
  end

  describe "#type" do
    it { expect(annotation.type).to eql("file_citation") }
  end

  describe "#text" do
    it { expect(annotation.text).to eql("[...]") }
  end

  describe "#start_index" do
    it { expect(annotation.start_index).to be(2) }
  end

  describe "#end_index" do
    it { expect(annotation.end_index).to be(4) }
  end

  describe "#file_id" do
    it { expect(annotation.file_id).to eql("file-123") }
  end

  describe "#file!" do
    subject(:file!) { annotation.file! }

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
