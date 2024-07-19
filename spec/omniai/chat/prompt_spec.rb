# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Prompt do
  subject(:prompt) { described_class.new(messages:) }

  let(:messages) { [] }

  describe '.build' do
    context 'with a block' do
      let(:prompt) { described_class.build { |prompt| prompt.user('How much does the averager elephant eat a day?') } }

      it { expect(prompt).to(be_a(described_class)) }
    end
  end

  describe '#inspect' do
    it { expect(prompt.inspect).to eql('#<OmniAI::Chat::Prompt messages=[]>') }
  end

  describe '#summarize' do
    it { expect(prompt.summarize).to eql('') }
  end

  describe '#message' do
    context 'without some text or a block' do
      it { expect { prompt.message }.to raise_error(ArgumentError, 'content or block is required') }
    end

    context 'with some text' do
      let(:message) { prompt.message('What is the capital of Canada?') }

      it { expect { message }.to(change { prompt.messages.size }) }
    end

    context 'with a block' do
      let(:message) { prompt.message { |message| message.text('What is the capital of Canada?') } }

      it { expect { message }.to(change { prompt.messages.size }) }
    end
  end

  describe '#system' do
    context 'with some text' do
      let(:message) { prompt.system('You are a helpful assistant.') }

      it { expect { message }.to(change { prompt.messages.size }) }
    end

    context 'with a block' do
      let(:message) { prompt.system { |message| message.text('You are a helpful assistant.') } }

      it { expect { message }.to(change { prompt.messages.size }) }
    end
  end

  describe '#user' do
    context 'with some text' do
      let(:message) { prompt.user('What is the capital of Canada?') }

      it { expect { message }.to(change { prompt.messages.size }) }
    end

    context 'with a block' do
      let(:message) { prompt.user { |message| message.text('What is the capital of Canada?') } }

      it { expect { message }.to(change { prompt.messages.size }) }
    end
  end

  describe '#serialize' do
    subject(:serialize) { prompt.serialize }

    let(:messages) do
      [
        OmniAI::Chat::Message.new(role: 'system', content: 'You are an expert biologist.'),
        OmniAI::Chat::Message.new(role: 'system', content: 'Is a cheetah quicker than a human?'),
      ]
    end

    it do
      expect(serialize).to eql([
        { role: 'system', content: 'You are an expert biologist.' },
        { role: 'system', content: 'Is a cheetah quicker than a human?' },
      ])
    end
  end
end
