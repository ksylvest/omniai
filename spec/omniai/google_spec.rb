# frozen_string_literal: true

RSpec.describe OmniAI::Google do
  describe ".config" do
    it "returns an instance of OmniAI::Google::Config" do
      expect(described_class.config).to be_an_instance_of(OmniAI::Google::Config)
    end
  end
end
