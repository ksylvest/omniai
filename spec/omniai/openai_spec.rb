# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI do
  describe ".config" do
    it "returns an instance of OmniAI::OpenAI::Config" do
      expect(described_class.config).to be_an_instance_of(OmniAI::OpenAI::Config)
    end
  end
end
