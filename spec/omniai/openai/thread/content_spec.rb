# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Thread::Content do
  subject(:content) { described_class.new(data:, client:) }

  let(:client) { OmniAI::OpenAI::Client.new }

  let(:data) do
    {
      "type" => type,
      "text" => {
        "value" => "Hello!",
        "annotations" => [],
      },
    }
  end
  let(:type) { "text" }

  describe ".for" do
    context "with enumerable data" do
      it { expect(described_class.for(data: [data], client:)).to be_a(Array) }
    end

    context "without enumerable data" do
      it { expect(described_class.for(data: "Hello!", client:)).to eql("Hello!") }
    end
  end

  describe "#type" do
    it { expect(content.type).to eql("text") }
  end

  describe "#text" do
    it { expect(content.text).to be_a(OmniAI::OpenAI::Thread::Text) }
    it { expect(content.text.value).to eql("Hello!") }
  end

  describe "#text?" do
    context 'when type is "text"' do
      let(:type) { "text" }

      it { expect(content).to be_text }
    end

    context 'when type is "other"' do
      let(:type) { "other" }

      it { expect(content).not_to be_text }
    end
  end
end
