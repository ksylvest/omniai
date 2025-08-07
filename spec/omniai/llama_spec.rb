# frozen_string_literal: true

RSpec.describe OmniAI::Llama do
  describe ".config" do
    it "returns an instance of OmniAI::Llama::Config" do
      expect(described_class.config).to be_an_instance_of(OmniAI::Llama::Config)
    end
  end
end
