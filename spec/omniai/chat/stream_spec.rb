# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Stream do
  subject(:stream) { build(:chat_stream, chunks:) }

  describe ".stream!" do
    subject(:stream!) { stream.stream! }

    let(:chunks) do
      [
        "data: #{JSON.generate({
          id: 'chunk',
          object: 'chat.completion.chunk',
          choices: [{ delta: { role: 'assistant', content: '' } }],
        })}\n\n",
        "data: #{JSON.generate({
          id: 'chunk',
          object: 'chat.completion.chunk',
          choices: [{ delta: { content: 'A' } }],
        })}\n\n",
        "data: #{JSON.generate({
          id: 'chunk',
          object: 'chat.completion.chunk',
          choices: [{ delta: { content: 'B' } }],
        })}\n\n",
        "data: [DONE]\n",
      ]
    end

    it "processes the payload" do
      expect(stream!.map(&:text)).to eq(["", "A", "B"])
    end
  end
end
