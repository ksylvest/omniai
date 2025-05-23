# frozen_string_literal: true

RSpec.describe OmniAI::HTTPError do
  subject(:error) { described_class.new(response) }

  let(:response) { instance_double(HTTP::Response, status:, body:) }

  let(:status) { 500 }
  let(:body) { "Internal Server Error" }

  describe "#inspect" do
    it "returns a string representation of the error" do
      expect(error.inspect).to eq("#<OmniAI::HTTPError status=500 body=Internal Server Error>")
    end
  end
end
