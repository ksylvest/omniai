# frozen_string_literal: true

RSpec.describe OmniAI do
  it "has a version number" do
    expect(described_class::VERSION).not_to be_nil
  end

  describe ".chat" do
    subject(:chat) { described_class.chat(prompt, model:) }

    let(:client) { instance_double(OmniAI::Client) }
    let(:prompt) { "What is the capital of Canada?" }
    let(:model) { "davinci" }

    it "delegates to 'OmniAI::Client#chat'" do
      allow(OmniAI::Client).to receive(:discover).and_return(client)
      allow(client).to receive(:chat)
      chat
      expect(client).to have_received(:chat).with(prompt, model:)
    end
  end

  describe ".transcribe" do
    subject(:transcribe) { described_class.transcribe(io, model:) }

    let(:client) { instance_double(OmniAI::Client) }
    let(:io) { instance_double(IO) }
    let(:model) { "davinci" }

    it "delegates to 'OmniAI::Client#transcribe'" do
      allow(OmniAI::Client).to receive(:discover).and_return(client)
      allow(client).to receive(:transcribe)
      transcribe
      expect(client).to have_received(:transcribe).with(io, model:)
    end
  end

  describe ".speak" do
    subject(:speak) { described_class.speak(input, model:, voice:) }

    let(:client) { instance_double(OmniAI::Client) }
    let(:input) { "Sally sells seashells by the seashore." }
    let(:model) { "davinci" }
    let(:voice) { "human" }

    it "delegates to 'OmniAI::Client#speak'" do
      allow(OmniAI::Client).to receive(:discover).and_return(client)
      allow(client).to receive(:speak)
      speak
      expect(client).to have_received(:speak).with(input, model:, voice:)
    end
  end

  describe ".embed" do
    subject(:embed) { described_class.embed(input, model:) }

    let(:client) { instance_double(OmniAI::Client) }
    let(:input) { "Sally sells seashells by the seashore." }
    let(:model) { "davinci" }

    it "delegates to 'OmniAI::Client#embed'" do
      allow(OmniAI::Client).to receive(:discover).and_return(client)
      allow(client).to receive(:embed)
      embed
      expect(client).to have_received(:embed).with(input, model:)
    end
  end
end
