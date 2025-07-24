# frozen_string_literal: true

RSpec.describe OmniAI::Llama::Chat do
  let(:client) { OmniAI::Llama::Client.new }

  describe ".process!" do
    subject(:completion) { described_class.process!(prompt, client:, model:) }

    let(:model) { described_class::DEFAULT_MODEL }

    context "with a basic prompt" do
      let(:prompt) { "Tell me a joke!" }

      before do
        stub_request(:post, "https://api.llama.com/v1/chat/completions")
          .with(body: {
            messages: [{ role: "user", content: [{ type: "text", text: "Tell me a joke!" }] }],
            model:,
          })
          .to_return_json(body: {
            completion_message: {
              role: "assistant",
              content: {
                type: "text",
                text: "Two elephants fall off a cliff. Boom! Boom!",
              },
            },
          })
      end

      it { expect(completion.text).to eql("Two elephants fall off a cliff. Boom! Boom!") }
    end

    context "with an advanced prompt" do
      let(:prompt) do
        OmniAI::Chat::Prompt.build do |prompt|
          prompt.system("You are a helpful assistant.")
          prompt.user("What is the capital of Canada?")
        end
      end

      before do
        stub_request(:post, "https://api.llama.com/v1/chat/completions")
          .with(body: {
            messages: [
              { role: "system", content: [{ type: "text", text: "You are a helpful assistant." }] },
              { role: "user", content: [{ type: "text", text: "What is the capital of Canada?" }] },
            ],
            model:,
          })
          .to_return_json(body: {
            completion_message: {
              role: "assistant",
              content: {
                type: "text",
                text: "The capital of Canada is Ottawa.",
              },
            },
          })
      end

      it { expect(completion.text).to eql("The capital of Canada is Ottawa.") }
    end

    context "with a temperature" do
      subject(:completion) { described_class.process!(prompt, client:, model:, temperature:) }

      let(:prompt) { "Pick a number between 1 and 5." }
      let(:temperature) { 2.0 }

      before do
        stub_request(:post, "https://api.llama.com/v1/chat/completions")
          .with(body: {
            messages: [{ role: "user", content: [{ type: "text", text: "Pick a number between 1 and 5." }] }],
            model:,
            temperature:,
          })
          .to_return_json(body: {
            completion_message: {
              role: "assistant",
              content: {
                type: "text",
                text: "3",
              },
            },
          })
      end

      it { expect(completion.text).to eql("3") }
    end

    context "when formatting as JSON" do
      subject(:completion) { described_class.process!(prompt, client:, model:, format: :json) }

      let(:prompt) do
        OmniAI::Chat::Prompt.build do |prompt|
          prompt.system(OmniAI::Chat::JSON_PROMPT)
          prompt.user("What is the name of the dummer for the Beatles?")
        end
      end

      before do
        stub_request(:post, "https://api.llama.com/v1/chat/completions")
          .with(body: {
            messages: [
              { role: "system", content: [{ type: "text", text: OmniAI::Chat::JSON_PROMPT }] },
              { role: "user", content: [{ type: "text", text: "What is the name of the dummer for the Beatles?" }] },
            ],
            model:,
            response_format: { type: "json_object" },
          })
          .to_return_json(body: {
            completion_message: {
              role: "assistant",
              content: {
                type: "text",
                text: '{ "name": "Ringo" }',
              },
            },
          })
      end

      it { expect(completion.text).to eql('{ "name": "Ringo" }') }
    end

    context "when streaming" do
      subject(:completion) { described_class.process!(prompt, client:, model:, stream:) }

      let(:prompt) { "Tell me a story." }
      let(:stream) { proc { |chunk| chunks << chunk } }
      let(:chunks) { [] }

      before do
        stub_request(:post, "https://api.llama.com/v1/chat/completions")
          .with(body: {
            messages: [
              { role: "user", content: [{ type: "text", text: "Tell me a story." }] },
            ],
            model:,
            stream: true,
          })
          .to_return(body: <<~STREAM)
            data: #{JSON.generate({ event: { delta: { type: 'text', text: '' } } })}\n
            data: #{JSON.generate({ event: { delta: { type: 'text', text: 'Hello' } } })}\n
            data: #{JSON.generate({ event: { delta: { type: 'text', text: ' ' } } })}\n
            data: #{JSON.generate({ event: { delta: { type: 'text', text: 'World' } } })}\n
            data: #{JSON.generate({ event: { metrics: [] } })}\n
            data: [DONE]\n
          STREAM
      end

      it { expect(completion.text).to eql("Hello World") }
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
        stub_request(:post, "https://api.llama.com/v1/chat/completions")
          .with(body: {
            messages: [
              {
                role: "user",
                content: [
                  { type: "text", text: "What are these photos of?" },
                  { type: "image_url", image_url: { url: "https://localhost/cat.jpg" } },
                  { type: "image_url", image_url: { url: "https://localhost/dog.jpg" } },
                  { type: "image_url", image_url: { url: "data:image/jpeg;base64," } },
                ],
              },
            ],
            model:,
          })
          .to_return_json(body: {
            completion_message: {
              role: "assistant",
              content: {
                type: "text",
                text: "They are a photo of a cat and a photo of a dog.",
              },
            },
          })
      end

      it { expect(completion.text).to eql("They are a photo of a cat and a photo of a dog.") }
    end
  end
end
