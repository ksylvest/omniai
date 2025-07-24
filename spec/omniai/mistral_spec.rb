# frozen_string_literal: true

RSpec.describe OmniAI::Mistral do
  describe ".config" do
    it "returns an instance of OmniAI::Mistral::Config" do
      expect(described_class.config).to be_an_instance_of(OmniAI::Mistral::Config)
    end
  end
end
