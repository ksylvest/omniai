# frozen_string_literal: true

RSpec.describe OmniAI::Anthropic do
  describe ".config" do
    it "returns an instance of OmniAI::Anthropic::Config" do
      expect(described_class.config).to be_an_instance_of(OmniAI::Anthropic::Config)
    end
  end
end
