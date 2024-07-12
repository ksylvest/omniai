# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Response::Part do
  subject(:part) { described_class.new(data:) }

  let(:data) do
    {
      'role' => 'system',
      'content' => 'Hello!',
      'tool_calls' => [
        {
          'id' => 'fake_tool_call_id',
          'type' => 'function',
          'function' => {
            'name' => 'temperature',
            'arguments' => '{"unit":"celsius"}',
          },
        },
      ],
    }
  end

  describe '#role' do
    it { expect(part.role).to eq('system') }
  end

  describe '#content' do
    it { expect(part.content).to eq('Hello!') }
  end

  describe '#tool_call_list' do
    it { expect(part.tool_call_list).not_to be_empty }
  end

  describe '#tool_call' do
    it { expect(part.tool_call).to be_a(OmniAI::Chat::Response::ToolCall) }
  end
end
