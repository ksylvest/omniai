# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Thread::Text do
  subject(:text) { described_class.new(data:, client:) }

  let(:client) { OmniAI::OpenAI::Client.new }

  let(:data) do
    {
      "type" => "text",
      "value" => "Hello, [README].",
      "annotations" => [
        {
          "type" => "file_citation",
          "text" => "[README]",
          "start_index" => 2,
          "end_index" => 4,
          "file_citation" => { "file_id" => "file-123" },
        },
      ],
    }
  end

  describe "#type" do
    it { expect(text.type).to eql("text") }
  end

  describe "#value" do
    it { expect(text.value).to eql("Hello, [README].") }
  end

  describe "#annotate!" do
    subject(:annotate!) { text.annotate! }

    before do
      stub_request(:get, "https://api.openai.com/v1/files/file-123")
        .to_return_json(body: {
          id: "file-123",
          filename: "file.txt",
          purpose: "assistants",
          bytes: 1024,
        })
    end

    it { expect(annotate!).to eql("Hello, [file.txt:2..4].") }
  end
end
