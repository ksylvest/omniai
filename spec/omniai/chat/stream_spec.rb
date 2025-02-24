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
          choices: [{ index: 0, delta: { role: 'assistant', content: '' } }],
        })}\n\n",
        "data: #{JSON.generate({
          id: 'chunk',
          object: 'chat.completion.chunk',
          choices: [{ index: 0, delta: { content: 'A' } }],
        })}\n\n",
        "data: #{JSON.generate({
          id: 'chunk',
          object: 'chat.completion.chunk',
          choices: [{ index: 0, delta: { content: 'B' } }],
        })}\n\n",
        "data: [DONE]\n",
      ]
    end

    it { expect(stream!).to be_a(OmniAI::Chat::Payload) }
    it { expect(stream!.text).to eql("AB") }
  end
end
