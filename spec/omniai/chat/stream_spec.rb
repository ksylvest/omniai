# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Stream do
  subject(:stream) { build(:chat_stream, chunks:) }

  describe ".stream!" do
    subject(:stream!) { stream.stream! }

    let(:chunks) do
      [
        {
          id: "chunk",
          object: "chat.completion.chunk",
          choices: [{ index: 0, delta: { role: "assistant", content: "" } }],
        },
        {
          id: "chunk",
          object: "chat.completion.chunk",
          choices: [{ index: 0, delta: { content: "A" } }],
        },
        {
          id: "chunk",
          object: "chat.completion.chunk",
          choices: [{ index: 0, delta: { content: "B" } }],
        },
      ].map { |chunk| "data: #{JSON.generate(chunk)}\n\n" }
    end

    it { expect(stream!).to be_a(OmniAI::Chat::Payload) }
    it { expect(stream!.text).to eql("AB") }
  end
end
