# frozen_string_literal: true

RSpec.describe OmniAI::CLI::BaseHandler do
  describe '.handle!' do
    let(:argv) { [] }

    it 'raises an error' do
      expect { described_class.handle!(argv:) }.to raise_error(NotImplementedError)
    end
  end
end
