# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::File do
  let(:client) { OmniAI::OpenAI::Client.new }

  describe "#inspect" do
    subject(:inspect) { file.inspect }

    let(:file) { described_class.new(client:, id: "file-123", filename: "README.md") }

    it { is_expected.to eql('#<OmniAI::OpenAI::File id="file-123" filename="README.md">') }
  end

  describe ".find" do
    subject(:find) { described_class.find(id: "file-123", client:) }

    context "with an OK response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/files/file-123")
          .to_return_json(body: {
            id: "file-123",
            bytes: 1024,
            filename: "file.txt",
            purpose: "assistants",
          })
      end

      it { expect(find.id).to eql("file-123") }
      it { expect(find.bytes).to be(1024) }
      it { expect(find.filename).to eql("file.txt") }
      it { expect(find.purpose).to eql("assistants") }
    end

    context "with a MISSING response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/files/file-123")
          .to_return_json(status: 404)
      end

      it { expect { find }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe ".all" do
    subject(:all) { described_class.all(client:) }

    context "with an OK response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/files")
          .to_return_json(body: {
            data: [
              {
                id: "file-123",
                bytes: 1024,
                filename: "file.txt",
                purpose: "assistants",
              },
            ],
          })
      end

      it { expect(all).to be_an(Array) }
    end

    context "with a UNPROCESSABLE response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/files")
          .to_return(status: 422)
      end

      it { expect { all }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe ".destroy!" do
    subject(:destroy!) { described_class.destroy!(id: "file-123", client:) }

    context "with an OK response" do
      before do
        stub_request(:delete, "https://api.openai.com/v1/files/file-123")
          .to_return_json(body: {
            id: "files-123",
            deleted: true,
          })
      end

      it { expect(destroy!["id"]).to eql("files-123") }
      it { expect(destroy!["deleted"]).to be_truthy }
    end

    context "with a MISSING response" do
      before do
        stub_request(:delete, "https://api.openai.com/v1/files/file-123")
          .to_return_json(status: 404)
      end

      it { expect { destroy! }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe "#destroy!" do
    subject(:destroy!) { file.destroy! }

    let(:file) { described_class.new(client:, id: "file-123", filename: "README.md", bytes: 1024) }

    context "with an OK response" do
      before do
        stub_request(:delete, "https://api.openai.com/v1/files/file-123")
          .to_return_json(body: {
            id: "file-123",
            deleted: true,
          })
      end

      it { expect { destroy! }.to change(file, :deleted).from(nil).to(true) }
    end

    context "with a MISSING response" do
      before do
        stub_request(:delete, "https://api.openai.com/v1/files/file-123")
          .to_return_json(status: 404)
      end

      it { expect { destroy! }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe "#save!" do
    subject(:save!) { file.save! }

    context "without IO" do
      let(:file) { described_class.new(client:) }

      it { expect { save! }.to raise_error(OmniAI::Error, "cannot save a file without IO") }
    end

    context "with IO" do
      let(:file) { described_class.new(client:, io: StringIO.new("Hello!")) }

      context "with an OK response" do
        before do
          stub_request(:post, "https://api.openai.com/v1/files")
            .to_return_json(body: {
              id: "file-123",
              bytes: 1024,
              filename: "file.txt",
              purpose: "assistants",
            })
        end

        it { expect(save!.id).to eql("file-123") }
        it { expect(save!.bytes).to be(1024) }
        it { expect(save!.filename).to eql("file.txt") }
        it { expect(save!.purpose).to eql("assistants") }
      end

      context "with an UNPROCESSABLE response" do
        before do
          stub_request(:post, "https://api.openai.com/v1/files")
            .to_return(status: 422)
        end

        it { expect { save! }.to raise_error(OmniAI::HTTPError) }
      end
    end
  end

  describe "#content" do
    context "without an ID" do
      let(:file) { described_class.new(client:) }

      it { expect { |block| file.content(&block) }.to raise_error(OmniAI::Error, "cannot fetch content without ID") }
    end

    context "with an ID" do
      let(:file) { described_class.new(client:, id: "file-123") }

      before do
        stub_request(:get, "https://api.openai.com/v1/files/file-123/content")
          .to_return(body: "Hello World!")
      end

      it { expect { |block| file.content(&block) }.to yield_with_args("Hello World!") }
    end
  end
end
