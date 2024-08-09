# frozen_string_literal: true

RSpec.describe OmniAI::Chat::ToolCallMessage do
  subject(:tool_call_message) { build(:chat_tool_call_message, content:, tool_call_id:) }

  let(:content) { 'Hello!' }
  let(:tool_call_id) { 'fake_id' }

  describe '#inspect' do
    subject(:inspect) { tool_call_message.inspect }

    it { expect(inspect).to eql('#<OmniAI::Chat::ToolCallMessage content="Hello!" tool_call_id="fake_id">') }
  end

  describe '.deserialize' do
    subject(:deserialize) { described_class.deserialize(data, context:) }

    let(:data) { { 'role' => 'tool', 'content' => '"Hello!"', 'tool_call_id' => 'fake_id' } }

    context 'with a deserializer' do
      let(:context) do
        OmniAI::Context.build do |context|
          context.deserializers[:tool_call_message] = lambda do |data, *|
            role = data['role']
            content = JSON.parse(data['content'])
            tool_call_id = data['tool_call_id']
            described_class.new(content:, role:, tool_call_id:)
          end
        end
      end

      it { expect(deserialize).to be_a(described_class) }
      it { expect(deserialize.role).to eql('tool') }
      it { expect(deserialize.content).to eql('Hello!') }
      it { expect(deserialize.tool_call_id).to eql('fake_id') }
    end

    context 'without a deserializer' do
      let(:context) { OmniAI::Context.build }

      it { expect(deserialize).to be_a(described_class) }
      it { expect(deserialize.role).to eq('tool') }
      it { expect(deserialize.content).to eql('Hello!') }
      it { expect(deserialize.tool_call_id).to eql('fake_id') }
    end
  end

  describe '#serialize' do
    subject(:serialize) { tool_call_message.serialize(context:) }

    context 'with a serializer' do
      let(:context) do
        OmniAI::Context.build do |context|
          context.serializers[:tool_call_message] = lambda do |tool_call_message, *|
            {
              role: tool_call_message.role,
              content: JSON.generate(tool_call_message.content),
              tool_call_id: tool_call_message.tool_call_id,
            }
          end
        end
      end

      it do
        expect(serialize).to eql({
          role: 'tool',
          content: '"Hello!"',
          tool_call_id: 'fake_id',
        })
      end
    end

    context 'without a serializer' do
      let(:context) { OmniAI::Context.build }

      it do
        expect(serialize).to eql({
          role: 'tool',
          content: '"Hello!"',
          tool_call_id: 'fake_id',
        })
      end
    end
  end
end
