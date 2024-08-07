# frozen_string_literal: true

module OmniAI
  # An abstract class that provides a consistent interface for processing chat requests.
  #
  # Usage:
  #
  #   class OmniAI::OpenAI::Chat < OmniAI::Chat
  #     module Model
  #       GPT_4O = "gpt-4o"
  #     end
  #
  #     protected
  #
  #     # @return [Hash]
  #     def payload
  #       raise NotImplementedError, "#{self.class.name}#payload undefined"
  #     end
  #
  #     # @return [String]
  #     def path
  #       raise NotImplementedError, "#{self.class.name}#path undefined"
  #     end
  #   end
  #
  #   client.chat(messages, model: "...", temperature: 0.0, format: :text)
  class Chat
    JSON_PROMPT = 'Respond with valid JSON. Do not include any non-JSON in the response.'

    # An error raised when a chat makes a tool-call for a tool that cannot be found.
    class ToolCallLookupError < Error
      def initialize(tool_call)
        super("missing tool for tool_call=#{tool_call.inspect}")
        @tool_call = tool_call
      end
    end

    module Role
      ASSISTANT = 'assistant'
      USER = 'user'
      SYSTEM = 'system'
      TOOL = 'tool'
    end

    module Format
      JSON = :json
    end

    def self.process!(...)
      new(...).process!
    end

    # @param prompt [OmniAI::Chat::Prompt, String, nil] optional
    # @param client [OmniAI::Client] the client
    # @param model [String] required
    # @param temperature [Float, nil] optional
    # @param stream [Proc, IO, nil] optional
    # @param tools [Array<OmniAI::Tool>] optional
    # @param format [Symbol, nil] optional - :json
    #
    # @yield [prompt] optional
    # @yieldparam prompt [OmniAI::Chat::Prompt]
    #
    # @return [OmniAi::Chat]
    def initialize(prompt = nil, client:, model:, temperature: nil, stream: nil, tools: nil, format: nil, &block)
      raise ArgumentError, 'prompt or block is required' if !prompt && !block

      @prompt = prompt ? Prompt.parse(prompt) : Prompt.new
      block&.call(@prompt)

      @client = client
      @model = model
      @temperature = temperature
      @stream = stream
      @tools = tools
      @format = format
    end

    # @raise [HTTPError]
    def process!
      response = request!

      raise HTTPError, response.flush unless response.status.ok?

      parse!(response:)
    end

    protected

    # Used to spawn another chat with the same configuration using different messages.
    #
    # @param prompt [OmniAI::Chat::Prompt]
    # @return [OmniAI::Chat::Prompt]
    def spawn!(prompt)
      self.class.new(
        prompt,
        client: @client,
        model: @model,
        temperature: @temperature,
        stream: @stream,
        tools: @tools,
        format: @format
      ).process!
    end

    # @return [Hash]
    def payload
      raise NotImplementedError, "#{self.class.name}#payload undefined"
    end

    # @return [String]
    def path
      raise NotImplementedError, "#{self.class.name}#path undefined"
    end

    # @param response [HTTP::Response]
    # @return [OmniAI::Chat::Response::Completion]
    def parse!(response:)
      if @stream
        stream!(response:)
      else
        complete!(response:)
      end
    end

    # @param response [HTTP::Response]
    # @return [OmniAI::Chat::Response::Completion]
    def complete!(response:)
      completion = self.class::Response::Completion.new(data: response.parse)

      if @tools && completion.tool_call_list.any?
        spawn!([
          *@prompt.serialize,
          *completion.choices.map(&:message).map(&:data),
          *(completion.tool_call_list.map { |tool_call| execute_tool_call(tool_call) }),
        ])
      else
        completion
      end
    end

    # @param response [HTTP::Response]
    # @return [OmniAI::Chat::Response::Stream]
    def stream!(response:)
      raise Error, "#{self.class.name}#stream! unstreamable" unless @stream

      self.class::Response::Stream.new(response:).stream! do |chunk|
        case @stream
        when IO, StringIO
          if chunk.content?
            @stream << chunk.content
            @stream.flush
          end
        else @stream.call(chunk)
        end
      end

      @stream.puts if @stream.is_a?(IO) || @stream.is_a?(StringIO)
    end

    # @return [HTTP::Response]
    def request!
      @client
        .connection
        .accept(:json)
        .post(path, json: payload)
    end

    # @param tool_call [OmniAI::Chat::ToolCall]
    def execute_tool_call(tool_call)
      function = tool_call.function

      tool = @tools.find { |entry| function.name == entry.name } || raise(ToolCallLookupError, tool_call)
      result = tool.call(function.arguments)

      prepare_tool_call_message(tool_call:, content: result)
    end

    # @param tool_call [OmniAI::Chat::ToolCall]
    # @param content [String]
    def prepare_tool_call_message(tool_call:, content:)
      {
        role: Role::TOOL,
        name: tool_call.function.name,
        tool_call_id: tool_call.id,
        content:,
      }
    end
  end
end
