# frozen_string_literal: true

class FakeClient < OmniAI::Client
  def connection
    HTTP.persistent("http://localhost:8080")
  end
end

class FakeChat < OmniAI::Chat
  module Model
    FAKE = "fake"
  end

  def path
    "/chat"
  end

  def payload
    { messages: @prompt.serialize, model: @model }
  end
end

RSpec.describe OmniAI::Chat do
  subject(:chat) { described_class.new(prompt, model:, client:) }

  let(:model) { "..." }
  let(:client) { OmniAI::Client.new(api_key: "...") }

  let(:prompt) do
    OmniAI::Chat::Prompt.new.tap do |prompt|
      prompt.system("You are a helpful assistant.")
      prompt.user("What is the name of the drummer for the Beatles?")
    end
  end

  describe "#initialize" do
    context "with a prompt" do
      it "returns a chat" do
        expect(described_class.new("What is the capital of France", model:, client:))
          .to be_a(described_class)
      end
    end

    context "with a block" do
      it "returns a chat" do
        expect(described_class.new(model:, client:) { |prompt| prompt.user("What is the capital of Spain") })
          .to be_a(described_class)
      end
    end

    context "without a prompt or block" do
      it "raises an error" do
        expect { described_class.new(model:, client:) }
          .to raise_error(ArgumentError, "prompt or block is required")
      end
    end
  end

  describe "#path" do
    it { expect { chat.send(:path) }.to raise_error(NotImplementedError) }
  end

  describe "#payload" do
    it { expect { chat.send(:payload) }.to raise_error(NotImplementedError) }
  end

  describe ".process!" do
    subject(:process!) { FakeChat.process!(prompt, model:, client:, stream:) }

    let(:stream) { nil }
    let(:client) { FakeClient.new(api_key: "...") }
    let(:model) { FakeChat::Model::FAKE }

    context "when OK" do
      before do
        stub_request(:post, "http://localhost:8080/chat")
          .with(body: {
            messages: [
              { role: "system", content: [{ type: "text", text: "You are a helpful assistant." }] },
              { role: "user", content: [{ type: "text", text: "What is the name of the drummer for the Beatles?" }] },
            ],
            model:,
          })
          .to_return_json(status: 200, body: {
            choices: [{
              index: 0,
              message: {
                role: "assistant",
                content: "Ringo!",
              },
            }],
          })
      end

      it { expect(process!).to be_a(OmniAI::Chat::Response) }
      it { expect(process!.text).to eql("Ringo!") }
    end

    context "when UNPROCESSABLE" do
      before do
        stub_request(:post, "http://localhost:8080/chat")
          .with(body: {
            messages: [
              { role: "system", content: [{ type: "text", text: "You are a helpful assistant." }] },
              { role: "user", content: [{ type: "text", text: "What is the name of the drummer for the Beatles?" }] },
            ],
            model:,
          })
          .to_return(status: 422, body: "An unknown error occurred.")
      end

      it { expect { process! }.to raise_error(OmniAI::HTTPError) }
    end

    context "when OK with stream using a proc" do
      let(:stream) { proc { |chunk| chunks << chunk } }
      let(:chunks) { [] }

      before do
        stub_request(:post, "http://localhost:8080/chat")
          .with(body: {
            messages: [
              { role: "system", content: [{ type: "text", text: "You are a helpful assistant." }] },
              { role: "user", content: [{ type: "text", text: "What is the name of the drummer for the Beatles?" }] },
            ],
            model:,
          })
          .to_return(status: 200, body: <<~STREAM)
            data: #{JSON.generate({ choices: [{ index: 0, delta: { role: 'assistant', content: '' } }] })}\n\n
            data: #{JSON.generate({ choices: [{ index: 0, delta: { role: 'assistant', content: 'Hello' } }] })}\n\n
            data: #{JSON.generate({ choices: [{ index: 0, delta: { role: 'assistant', content: ' ' } }] })}\n\n
            data: #{JSON.generate({ choices: [{ index: 0, delta: { role: 'assistant', content: 'World' } }] })}\n\n
            data: [DONE]\n\n
          STREAM
      end

      it { expect(process!).to be_a(OmniAI::Chat::Response) }
      it { expect(process!.text).to eql("Hello World") }

      it do
        process!
        expect(chunks.filter(&:text?).map(&:text)).to eql([
          "Hello",
          " ",
          "World",
        ])
      end
    end

    context "when OK with stream using IO" do
      let(:stream) { StringIO.new }

      before do
        stub_request(:post, "http://localhost:8080/chat")
          .with(body: {
            messages: [
              { role: "system", content: [{ type: "text", text: "You are a helpful assistant." }] },
              { role: "user", content: [{ type: "text", text: "What is the name of the drummer for the Beatles?" }] },
            ],
            model:,
          })
          .to_return(status: 200, body: <<~STREAM)
            data: #{JSON.generate({ choices: [{ index: 0, delta: { role: 'assistant', content: '' } }] })}\n\n
            data: #{JSON.generate({ choices: [{ index: 0, delta: { role: 'assistant', content: 'A' } }] })}\n\n
            data: #{JSON.generate({ choices: [{ index: 0, delta: { role: 'assistant', content: 'B' } }] })}\n\n
            data: [DONE]\n\n
          STREAM
      end

      it do
        process!
        expect(stream.string).to eql("AB\n")
      end
    end

    context "when UNPROCESSABLE with stream" do
      let(:stream) { proc { |chunk| chunks << chunk } }
      let(:chunks) { [] }

      before do
        stub_request(:post, "http://localhost:8080/chat")
          .with(body: {
            messages: [
              { role: "system", content: [{ type: "text", text: "You are a helpful assistant." }] },
              { role: "user", content: [{ type: "text", text: "What is the name of the drummer for the Beatles?" }] },
            ],
            model:,
          })
          .to_return(status: 422, body: "An unknown error occurred.")
      end

      it { expect { process! }.to raise_error(OmniAI::HTTPError) }
    end

    context "when an SSL error occures" do
      before do
        stub_request(:post, "http://localhost:8080/chat")
          .with(body: {
            messages: [
              { role: "system", content: [{ type: "text", text: "You are a helpful assistant." }] },
              { role: "user", content: [{ type: "text", text: "What is the name of the drummer for the Beatles?" }] },
            ],
            model:,
          })
          .to_raise(OpenSSL::SSL::SSLError, "an unknown error occurred")
      end

      it { expect { process! }.to raise_error(OmniAI::SSLError) }
    end
  end
end
