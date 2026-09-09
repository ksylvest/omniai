# frozen_string_literal: true

class FakeChat < OmniAI::Chat
  # Raised by a spec's stream block to abort a runaway tool-call chain.
  class LoopGuardError < StandardError; end

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
    let(:client) { build(:client) }
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

    context "when tool calling with options" do
      subject(:process!) { FakeChat.process!(prompt, model:, client:, tools:, thinking: true) }

      let(:client) { build(:client) }
      let(:model) { FakeChat::Model::FAKE }
      let(:tool) { build(:tool) }
      let(:tools) { [tool] }

      before do
        stub_request(:post, "http://localhost:8080/chat")
          .with { |request| JSON.parse(request.body).dig("messages", -1, "role") != "tool" }
          .to_return_json(status: 200, body: {
            choices: [{
              index: 0,
              message: {
                role: "assistant",
                tool_calls: [{
                  id: "call_1",
                  type: "function",
                  function: { name: "weather", arguments: JSON.generate(location: "London") },
                }],
              },
            }],
          })

        stub_request(:post, "http://localhost:8080/chat")
          .with { |request| JSON.parse(request.body).dig("messages", -1, "role") == "tool" }
          .to_return_json(status: 200, body: {
            choices: [{
              index: 0,
              message: {
                role: "assistant",
                content: "The weather in London is Rainy.",
              },
            }],
          })
      end

      it "preserves options through spawn!" do
        chat = FakeChat.new(prompt, model:, client:, tools:, thinking: true)
        spawned = chat.send(:spawn!, prompt)
        expect(spawned.instance_variable_get(:@options)).to eql({ thinking: true })
      end

      it { expect(process!.text).to eql("The weather in London is Rainy.") }
    end

    context "when on_response is given with a multi-round tool chain" do
      subject(:process!) { FakeChat.process!(prompt, model:, client:, tools:, on_response:) }

      let(:tools) { [build(:tool)] }
      let(:responses) { [] }
      let(:on_response) { proc { |response| responses << response } }

      before do
        stub_request(:post, "http://localhost:8080/chat")
          .to_return_json(status: 200, body: {
            choices: [{
              index: 0,
              message: {
                role: "assistant",
                tool_calls: [{
                  id: "call_1",
                  type: "function",
                  function: { name: "weather", arguments: JSON.generate(location: "London") },
                }],
              },
            }],
            usage: { prompt_tokens: 10, completion_tokens: 5, total_tokens: 15 },
          })
          .to_return_json(status: 200, body: {
            choices: [{
              index: 0,
              message: {
                role: "assistant",
                tool_calls: [{
                  id: "call_2",
                  type: "function",
                  function: { name: "weather", arguments: JSON.generate(location: "Madrid") },
                }],
              },
            }],
            usage: { prompt_tokens: 20, completion_tokens: 7, total_tokens: 27 },
          })
          .to_return_json(status: 200, body: {
            choices: [{
              index: 0,
              message: { role: "assistant", content: "London is Rainy and Madrid is Sunny." },
            }],
            usage: { prompt_tokens: 30, completion_tokens: 9, total_tokens: 39 },
          })
      end

      it "yields each completed round's own usage" do
        process!
        expect(responses.map { |response| response.usage.total_tokens }).to eql([15, 27, 39])
      end

      it "yields usages that sum to the final total_usage" do
        response = process!
        expect(responses.sum { |entry| entry.usage.total_tokens }).to eql(response.total_usage.total_tokens)
      end
    end

    context "when a stream block aborts a multi-round tool chain" do
      subject(:process!) { FakeChat.process!(prompt, model:, client:, tools:, stream:, on_response:) }

      let(:tools) { [build(:tool)] }
      let(:responses) { [] }
      let(:on_response) { proc { |response| responses << response } }

      # A loop guard in the shape the caller would write: abort the stream once two rounds have completed.
      let(:stream) { proc { |_delta| raise FakeChat::LoopGuardError if responses.length >= 2 } }

      before do
        stub_request(:post, "http://localhost:8080/chat")
          .to_return(status: 200, body: <<~STREAM)
            data: #{JSON.generate({ choices: [{ index: 0, delta: { role: 'assistant', tool_calls: [{ index: 0, id: 'call_1', type: 'function', function: { name: 'weather', arguments: JSON.generate(location: 'London') } }] } }], usage: { prompt_tokens: 10, completion_tokens: 5, total_tokens: 15 } })}\n\n
            data: [DONE]\n\n
          STREAM
          .to_return(status: 200, body: <<~STREAM)
            data: #{JSON.generate({ choices: [{ index: 0, delta: { role: 'assistant', tool_calls: [{ index: 0, id: 'call_2', type: 'function', function: { name: 'weather', arguments: JSON.generate(location: 'Madrid') } }] } }], usage: { prompt_tokens: 20, completion_tokens: 7, total_tokens: 27 } })}\n\n
            data: [DONE]\n\n
          STREAM
          .to_return(status: 200, body: <<~STREAM)
            data: #{JSON.generate({ choices: [{ index: 0, delta: { role: 'assistant', content: 'London is' } }] })}\n\n
            data: #{JSON.generate({ choices: [{ index: 0, delta: { content: ' Rainy.' } }], usage: { prompt_tokens: 30, completion_tokens: 9, total_tokens: 39 } })}\n\n
            data: [DONE]\n\n
          STREAM
      end

      it { expect { process! }.to raise_error(FakeChat::LoopGuardError) }

      it "leaves the caller holding the usage for every round that completed" do
        expect { process! }.to raise_error(FakeChat::LoopGuardError)
        expect(responses.map { |response| response.usage.total_tokens }).to eql([15, 27])
      end
    end

    context "when a tool raises mid-chain" do
      subject(:process!) { FakeChat.process!(prompt, model:, client:, tools:, on_response:) }

      let(:tools) { [build(:tool)] }
      let(:responses) { [] }
      let(:on_response) { proc { |response| responses << response } }

      before do
        stub_request(:post, "http://localhost:8080/chat")
          .to_return_json(status: 200, body: {
            choices: [{
              index: 0,
              message: {
                role: "assistant",
                tool_calls: [{
                  id: "call_1",
                  type: "function",
                  function: { name: "weather", arguments: JSON.generate(location: "Atlantis") },
                }],
              },
            }],
            usage: { prompt_tokens: 10, completion_tokens: 5, total_tokens: 15 },
          })
      end

      it "yields the round before executing its tool calls" do
        expect { process! }.to raise_error(ArgumentError, "unknown location=Atlantis")
        expect(responses.map { |response| response.usage.total_tokens }).to eql([15])
      end
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
