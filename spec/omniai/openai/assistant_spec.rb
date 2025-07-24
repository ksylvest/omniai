# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Assistant do
  let(:client) { OmniAI::OpenAI::Client.new }

  describe "#inspect" do
    subject(:inspect) { assistant.inspect }

    let(:assistant) { described_class.new(client:, id: "asst-123", name: "Ringo", model: "gpt-4o") }

    it { is_expected.to eql('#<OmniAI::OpenAI::Assistant id="asst-123" name="Ringo" model="gpt-4o">') }
  end

  describe ".find" do
    subject(:find) { described_class.find(id: "asst-123", client:) }

    context "with an OK response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/assistants/asst-123")
          .to_return_json(body: {
            id: "asst-123",
            name: "Ringo",
            model: "gpt-4o",
            description: "Drummer",
            instructions: "Drum",
            metadata: { band: "The Beatles" },
          })
      end

      it { expect(find.id).to eql("asst-123") }
      it { expect(find.name).to eql("Ringo") }
      it { expect(find.model).to eql("gpt-4o") }
      it { expect(find.description).to eql("Drummer") }
      it { expect(find.instructions).to eql("Drum") }
      it { expect(find.metadata).to eql("band" => "The Beatles") }
    end

    context "with a MISSING response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/assistants/asst-123")
          .to_return_json(status: 404)
      end

      it { expect { find }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe ".all" do
    subject(:all) { described_class.all(client:) }

    context "with an OK response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/assistants")
          .to_return_json(body: {
            data: [
              {
                id: "asst-123",
                name: "Ringo",
                model: "gpt-4o",
                description: "Drummer",
                instructions: "Drum",
                metadata: { band: "The Beatles" },
              },
            ],
          })
      end

      it { expect(all).to be_an(Array) }
    end

    context "with a UNPROCESSABLE response" do
      before do
        stub_request(:get, "https://api.openai.com/v1/assistants")
          .to_return(status: 422)
      end

      it { expect { all }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe ".destroy!" do
    subject(:destroy!) { described_class.destroy!(id: "asst-123", client:) }

    context "with an OK response" do
      before do
        stub_request(:delete, "https://api.openai.com/v1/assistants/asst-123")
          .to_return_json(body: {
            id: "asst-123",
            deleted: true,
          })
      end

      it { expect(destroy!["id"]).to eql("asst-123") }
      it { expect(destroy!["deleted"]).to be_truthy }
    end

    context "with a MISSING response" do
      before do
        stub_request(:delete, "https://api.openai.com/v1/assistants/asst-123")
          .to_return_json(status: 404)
      end

      it { expect { destroy! }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe "#destroy!" do
    subject(:destroy!) { assistant.destroy! }

    let(:assistant) { described_class.new(client:, id: "asst-123", name: "Ringo", model: "gpt-4o") }

    context "with an OK response" do
      before do
        stub_request(:delete, "https://api.openai.com/v1/assistants/asst-123")
          .to_return_json(body: {
            id: "asst-123",
            deleted: true,
          })
      end

      it { expect { destroy! }.to change(assistant, :deleted).from(nil).to(true) }
    end

    context "with a MISSING response" do
      before do
        stub_request(:delete, "https://api.openai.com/v1/assistants/asst-123")
          .to_return_json(status: 404)
      end

      it { expect { destroy! }.to raise_error(OmniAI::HTTPError) }
    end
  end

  describe "#save!" do
    subject(:save!) { assistant.save! }

    context "when creating an assistant" do
      let(:assistant) { described_class.new(client:, name: "Ringo", model: "gpt-4o") }

      context "with an OK response" do
        before do
          stub_request(:post, "https://api.openai.com/v1/assistants")
            .to_return_json(body: {
              id: "asst-123",
              name: "Ringo",
              model: "gpt-4o",
              description: "Drummer",
              instructions: "Drum",
              metadata: { band: "The Beatles" },
            })
        end

        it { expect(save!.id).to eql("asst-123") }
        it { expect(save!.name).to eql("Ringo") }
        it { expect(save!.model).to eql("gpt-4o") }
        it { expect(save!.description).to eql("Drummer") }
        it { expect(save!.instructions).to eql("Drum") }
        it { expect(save!.metadata).to eql("band" => "The Beatles") }
      end

      context "with an UNPROCESSABLE response" do
        before do
          stub_request(:post, "https://api.openai.com/v1/assistants")
            .to_return(status: 422)
        end

        it { expect { save! }.to raise_error(OmniAI::HTTPError) }
      end
    end

    context "when updating an assistant" do
      let(:assistant) { described_class.new(client:, id: "asst-123", name: "Ringo", model: "gpt-4o") }

      context "with an OK response" do
        before do
          stub_request(:post, "https://api.openai.com/v1/assistants/asst-123")
            .to_return_json(body: {
              id: "asst-123",
              name: "Ringo",
              model: "gpt-4o",
              description: "Drummer",
              instructions: "Drum",
              metadata: { band: "The Beatles" },
            })
        end

        it { expect(save!.id).to eql("asst-123") }
        it { expect(save!.name).to eql("Ringo") }
        it { expect(save!.model).to eql("gpt-4o") }
        it { expect(save!.description).to eql("Drummer") }
        it { expect(save!.instructions).to eql("Drum") }
        it { expect(save!.metadata).to eql("band" => "The Beatles") }
      end

      context "with an UNPROCESSABLE response" do
        before do
          stub_request(:post, "https://api.openai.com/v1/assistants/asst-123")
            .to_return(status: 422)
        end

        it { expect { save! }.to raise_error(OmniAI::HTTPError) }
      end
    end
  end
end
