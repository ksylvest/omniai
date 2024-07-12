# frozen_string_literal: true

RSpec.describe OmniAI::Chat::Response::Resource do
  subject(:resource) { described_class.new(data: { name: 'Ringo' }) }

  describe '#data' do
    it 'returns data' do
      expect(resource.data).to eq({ name: 'Ringo' })
    end
  end

  describe '#inspect' do
    it 'returns inspect string' do
      expect(resource.inspect).to eq('#<OmniAI::Chat::Response::Resource data={:name=>"Ringo"}>')
    end
  end
end
