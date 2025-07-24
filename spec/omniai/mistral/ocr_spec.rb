# frozen_string_literal: true

RSpec.describe OmniAI::Mistral::OCR do
  let(:client) { OmniAI::Mistral::Client.new }

  describe ".process!" do
    subject(:ocr) { described_class.process!(document, kind:, client:) }

    let(:document) { "http://localhost/sample" }

    context "when kind is document" do
      let(:kind) { described_class::Kind::DOCUMENT }

      before do
        stub_request(:post, "https://api.mistral.ai/v1/ocr")
          .with(body: {
            model: "mistral-ocr-latest",
            document: {
              document_url: "http://localhost/sample",
              type: "document_url",
            },
          })
          .to_return_json(body: {
            pages: [
              {
                index: 0,
                markdown: "**Hello World**",
                images: [
                  { id: "image-1" },
                  { id: "image-2" },
                ],
                dimensions: {
                  dpi: 300,
                  width: 2200,
                  height: 1700,
                },
              },
            ],
            model: "mistral-ocr-latest",
          })
      end

      it { expect(ocr).to be_a(described_class::Response) }
      it { expect(ocr.pages[0]).to be_a(described_class::Page) }
      it { expect(ocr.pages[0].markdown).to eq("**Hello World**") }
      it { expect(ocr.pages[0].dimensions).to be_a(described_class::Dimensions) }
      it { expect(ocr.pages[0].dimensions.dpi).to eq(300) }
      it { expect(ocr.pages[0].dimensions.width).to eq(2200) }
      it { expect(ocr.pages[0].dimensions.height).to eq(1700) }
    end

    context "when kind is image" do
      let(:kind) { described_class::Kind::IMAGE }

      before do
        stub_request(:post, "https://api.mistral.ai/v1/ocr")
          .with(body: {
            model: "mistral-ocr-latest",
            document: {
              image_url: "http://localhost/sample",
              type: "image_url",
            },
          })
          .to_return_json(body: {
            pages: [
              {
                index: 0,
                markdown: "**Hello World**",
                images: [
                  { id: "image-1" },
                  { id: "image-2" },
                ],
                dimensions: {
                  dpi: 300,
                  width: 2200,
                  height: 1700,
                },
              },
            ],
            model: "mistral-ocr-latest",
          })
      end

      it { expect(ocr).to be_a(described_class::Response) }
      it { expect(ocr.pages[0]).to be_a(described_class::Page) }
      it { expect(ocr.pages[0].markdown).to eq("**Hello World**") }
      it { expect(ocr.pages[0].dimensions).to be_a(described_class::Dimensions) }
      it { expect(ocr.pages[0].dimensions.dpi).to eq(300) }
      it { expect(ocr.pages[0].dimensions.width).to eq(2200) }
      it { expect(ocr.pages[0].dimensions.height).to eq(1700) }
    end
  end
end
