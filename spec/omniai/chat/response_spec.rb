# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Response do
  subject(:response) { build(:chat_response, choices:, usage:) }

  let(:usage) { build(:chat_usage) }
  let(:choice) { build(:chat_choice, message:) }
  let(:message) { build(:chat_message, content: "Hello!") }
  let(:choices) { [choice] }

  describe "#inspect" do
    it {
      expect(response.inspect).to eql("#<OmniAI::Chat::Response choices=#{choices.inspect} usage=#{usage.inspect}>")
    }
  end

  describe ".deserialize" do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) do
      {
        "choices" => [],
        "usage" => {
          "input_tokens" => 0,
          "output_tokens" => 0,
          "total_tokens" => 0,
        },
      }
    end

    context "with a deserializer" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.deserializers[:response] = lambda { |data, *|
            choices = data["choices"].map { Choice.deserialize(data, context:) }
            usage = OmniAI::Chat::Usage.deserialize(data["usage"], context:)
            described_class.new(data:, choices:, usage:)
          }
        end
      end

      it { expect(deserialize).to be_a(described_class) }
    end

    context "without a serializer" do
      let(:context) { OmniAI::Context.build }

      it { expect(deserialize).to be_a(described_class) }
    end
  end

  describe "#serialize" do
    subject(:serialize) { response.serialize(context:) }

    context "with a serializer" do
      let(:context) do
        OmniAI::Context.build do |context|
          context.serializers[:response] = lambda do |response, *|
            {
              choices: response.choices.map { |choice| choice.serialize(context:) },
              usage: response.usage&.serialize(context:),
            }
          end
        end
      end

      it { expect(serialize).to eq(choices: [choice.serialize(context:)], usage: usage.serialize(context:)) }
    end

    context "without a serializer" do
      let(:context) { OmniAI::Context.build }

      it { expect(serialize).to eq(choices: [choice.serialize(context:)], usage: usage.serialize(context:)) }
    end
  end

  describe "#usage" do
    it "returns the usage" do
      expect(response.usage).to be_a(OmniAI::Chat::Usage)
    end
  end

  describe "#messages" do
    it "returns the messages" do
      expect(response.messages).to all(be_a(OmniAI::Chat::Message))
    end
  end

  describe "#text" do
    it "returns the content" do
      expect(response.text).to eq("Hello!")
    end
  end

  describe "#parent" do
    it "defaults to nil" do
      expect(response.parent).to be_nil
    end

    it "can be set" do
      parent = build(:chat_response)
      response.parent = parent
      expect(response.parent).to eq(parent)
    end
  end

  describe "#link_to" do
    let(:grandparent) { build(:chat_response) }
    let(:parent) { build(:chat_response) }

    it "links a single response to a parent" do
      response.link_to(parent)
      expect(response.parent).to eq(parent)
    end

    it "links a chain to a parent via the oldest response" do
      response.parent = parent
      response.link_to(grandparent)
      expect(parent.parent).to eq(grandparent)
    end
  end

  describe "#response_chain" do
    context "without parent" do
      it "returns array containing only self" do
        expect(response.response_chain).to eq([response])
      end
    end

    context "with parent chain" do
      let(:grandparent) { build(:chat_response) }
      let(:parent) { build(:chat_response) }

      before do
        parent.parent = grandparent
        response.parent = parent
      end

      it "returns chain from oldest to newest" do
        expect(response.response_chain).to eq([grandparent, parent, response])
      end
    end
  end

  describe "#total_usage" do
    context "without parent" do
      it "returns usage equivalent to self" do
        total = response.total_usage
        expect(total.input_tokens).to eq(usage.input_tokens)
        expect(total.output_tokens).to eq(usage.output_tokens)
      end
    end

    context "with parent chain" do
      let(:grandparent_usage) do
        OmniAI::Chat::Usage.new(input_tokens: 100, output_tokens: 50, total_tokens: 150)
      end
      let(:parent_usage) do
        OmniAI::Chat::Usage.new(input_tokens: 200, output_tokens: 100, total_tokens: 300)
      end
      let(:grandparent) { build(:chat_response, usage: grandparent_usage) }
      let(:parent) { build(:chat_response, usage: parent_usage) }

      before do
        parent.parent = grandparent
        response.parent = parent
      end

      it "aggregates input_tokens" do
        # grandparent(100) + parent(200) + self(2) = 302
        expect(response.total_usage.input_tokens).to eq(302)
      end

      it "aggregates output_tokens" do
        # grandparent(50) + parent(100) + self(3) = 153
        expect(response.total_usage.output_tokens).to eq(153)
      end

      it "calculates total_tokens from input + output" do
        expect(response.total_usage.total_tokens).to eq(302 + 153)
      end
    end

    context "when all usages are nil" do
      let(:usage) { nil }

      it "returns nil" do
        expect(response.total_usage).to be_nil
      end
    end

    context "when some usages are nil" do
      let(:parent_usage) do
        OmniAI::Chat::Usage.new(input_tokens: 200, output_tokens: 100, total_tokens: 300)
      end
      let(:parent) { build(:chat_response, usage: parent_usage) }
      let(:usage) { nil }

      before do
        response.parent = parent
      end

      it "aggregates only non-nil usages" do
        total = response.total_usage
        expect(total.input_tokens).to eq(200)
        expect(total.output_tokens).to eq(100)
      end
    end
  end
end
