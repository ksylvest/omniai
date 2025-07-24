# frozen_string_literal: true

RSpec.describe OmniAI::Google::Chat do
  let(:client) { OmniAI::Google::Client.new }

  describe ".process!" do
    subject(:completion) { described_class.process!(prompt, client:, model:) }

    let(:model) { described_class::Model::GEMINI_PRO }

    context "with a string prompt" do
      let(:prompt) { "Tell me a joke!" }

      before do
        stub_request(:post, "https://generativelanguage.googleapis.com/v1beta/models/#{model}:generateContent?key=#{client.api_key}")
          .with(body: {
            contents: [
              { role: "user", parts: [{ text: "Tell me a joke!" }] },
            ],
          })
          .to_return_json(body: {
            candidates: [{
              content: {
                role: "assistant",
                parts: [{ text: "Two elephants fall off a cliff. Boom! Boom!" }],
              },
            }],
          })
      end

      it { expect(completion.text).to eql("Two elephants fall off a cliff. Boom! Boom!") }
    end

    context "with an array prompt" do
      let(:prompt) do
        OmniAI::Chat::Prompt.build do |prompt|
          prompt.system("You are an expert in geography.")
          prompt.user("What is the capital of Canada?")
        end
      end

      before do
        stub_request(:post, "https://generativelanguage.googleapis.com/v1beta/models/#{model}:generateContent?key=#{client.api_key}")
          .with(body: {
            system_instruction: {
              role: "system",
              parts: [{ text: "You are an expert in geography." }],
            },
            contents: [{
              role: "user",
              parts: [{ text: "What is the capital of Canada?" }],
            }],
          })
          .to_return_json(body: {
            candidates: [{
              content: {
                role: "assistant",
                parts: [{ text: "The capital of Canada is Ottawa." }],
              },
            }],
          })
      end

      it { expect(completion.text).to eql("The capital of Canada is Ottawa.") }
    end

    context "with a temperature" do
      subject(:completion) { described_class.process!(prompt, client:, model:, temperature:) }

      let(:prompt) { "Pick a number between 1 and 5." }
      let(:temperature) { 2.0 }

      before do
        stub_request(:post, "https://generativelanguage.googleapis.com/v1beta/models/#{model}:generateContent?key=#{client.api_key}")
          .with(body: {
            generationConfig: { temperature: },
            contents: [
              { role: "user", parts: [{ text: prompt }] },
            ],
          })
          .to_return_json(body: {
            candidates: [{
              content: {
                role: "assistant",
                parts: [{ text: "3" }],
              },
            }],
          })
      end

      it { expect(completion.text).to eql("3") }
    end

    context "when streaming" do
      subject(:completion) { described_class.process!(prompt, client:, model:, stream:) }

      let(:prompt) { "Tell me a story." }
      let(:stream) { proc { |chunk| chunks << chunk } }
      let(:chunks) { [] }

      before do
        stub_request(:post, "https://generativelanguage.googleapis.com/v1beta/models/#{model}:streamGenerateContent?alt=sse&key=#{client.api_key}")
          .with(body: {
            contents: [
              { role: "user", parts: [{ text: prompt }] },
            ],
          })
          .to_return(body: <<~STREAM)
            data: #{JSON.generate(candidates: [{ content: { parts: [{ text: 'Hello' }], role: 'model' }, index: 0 }])}\n
            data: #{JSON.generate(candidates: [{ content: { parts: [{ text: ' ' }], role: 'model' }, index: 0 }])}\n
            data: #{JSON.generate(candidates: [{ content: { parts: [{ text: 'World' }], role: 'model' }, index: 0 }])}\n
          STREAM
      end

      it { expect(completion.text).to eql("Hello World") }
    end

    context "when formatting as JSON" do
      subject(:completion) { described_class.process!(prompt, client:, model:, format: :json) }

      let(:prompt) do
        OmniAI::Chat::Prompt.build do |prompt|
          prompt.user("What is the name of the dummer for the Beatles?")
        end
      end

      before do
        stub_request(:post, "https://generativelanguage.googleapis.com/v1beta/models/#{model}:generateContent?key=#{client.api_key}")
          .with(body: {
            generationConfig: { responseMimeType: "application/json" },
            contents: [
              {
                role: "user",
                parts: [{ text: "What is the name of the dummer for the Beatles?" }],
              },
            ],
          })
          .to_return_json(body: {
            candidates: [{
              index: 0,
              content: {
                role: "assistant",
                parts: [{ text: '{ "name": "Ringo" }' }],
              },
            }],
          })
      end

      it { expect(completion.text).to eql('{ "name": "Ringo" }') }
    end

    context "when using files / URLs" do
      let(:io) { Tempfile.new }

      let(:prompt) do
        OmniAI::Chat::Prompt.build do |prompt|
          prompt.user do |message|
            message.text("What are these photos of?")
            message.url("https://localhost/cat.jpg", "image/jpeg")
            message.url("https://localhost/dog.jpg", "image/jpeg")
            message.file(io, "image/jpeg")
          end
        end
      end

      before do
        stub_request(:get, "https://localhost/cat.jpg").to_return(body: "cat")
        stub_request(:get, "https://localhost/dog.jpg").to_return(body: "dog")
        stub_request(:post, "https://generativelanguage.googleapis.com/v1beta/models/#{model}:generateContent?key=#{client.api_key}")
          .with(body: {
            contents: [
              {
                role: "user",
                parts: [
                  { text: "What are these photos of?" },
                  { inlineData: { mimeType: "image/jpeg", data: "Y2F0" } },
                  { inlineData: { mimeType: "image/jpeg", data: "ZG9n" } },
                  { inlineData: { mimeType: "image/jpeg", data: "" } },
                ],
              },
            ],
          })
          .to_return_json(body: {
            candidates: [{
              content: {
                role: "assistant",
                parts: [{ text: "They are a photo of a cat and a photo of a dog." }],
              },
            }],
          })
      end

      it { expect(completion.text).to eql("They are a photo of a cat and a photo of a dog.") }
    end
  end
end
