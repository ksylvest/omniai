# frozen_string_literal: true

RSpec.describe OmniAI::DeepSeek do
  describe ".config" do
    it "returns an instance of OmniAI::Anthropic::Config" do
      expect(described_class.config).to be_an_instance_of(OmniAI::DeepSeek::Config)
    end
  end
end
