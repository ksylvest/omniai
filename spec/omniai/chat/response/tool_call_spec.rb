# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Response::ToolCall do
  subject(:tool_call) { described_class.new(data:) }

  let(:data) do
    {
      'id' => 'fake_tool_call_id',
      'type' => 'function',
      'function' => { 'name' => 'temperature', 'arguments' => '{"unit":"celsius"}' },
    }
  end

  it { expect(tool_call.id).to eq('fake_tool_call_id') }
  it { expect(tool_call.type).to eq('function') }
  it { expect(tool_call.function).to be_a(OmniAI::Chat::Response::Function) }

  describe '#inspect' do
    subject(:inspect) { tool_call.inspect }

    it { expect(inspect).to eq('#<OmniAI::Chat::Response::ToolCall id="fake_tool_call_id" type="function">') }
  end
end
