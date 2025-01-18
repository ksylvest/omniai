# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Response do
  subject(:response) { build(:chat_response, data:) }

  let(:data) do
    {
      "choices" => [
        { "index" => 0, "message" => { "role" => "system", "content" => "Hello!" } },
      ],
      "usage" => {
        "input_tokens" => 0,
        "output_tokens" => 0,
        "total_tokens" => 0,
      },
    }
  end

  describe "#data" do
    it "returns the data" do
      expect(response.data).to eq(data)
    end
  end

  describe "#completion" do
    it "returns the completion" do
      expect(response.completion).to be_a(OmniAI::Chat::Payload)
    end
  end

  describe "#usage" do
    it "returns the usage" do
      expect(response.usage).to be_a(OmniAI::Chat::Usage)
    end
  end

  describe "#choices" do
    it "returns the choices" do
      expect(response.choices).to all(be_a(OmniAI::Chat::Choice))
    end
  end

  describe "#messages" do
    it "returns the messages" do
      expect(response.messages).to all(be_a(OmniAI::Chat::Message))
    end
  end

  describe "#choice" do
    it "returns the choice" do
      expect(response.choice).to be_a(OmniAI::Chat::Choice)
    end
  end

  describe "#message" do
    it "returns the message" do
      expect(response.message).to be_a(OmniAI::Chat::Message)
    end
  end

  describe "#text" do
    it "returns the content" do
      expect(response.text).to eq("Hello!")
    end
  end
end
