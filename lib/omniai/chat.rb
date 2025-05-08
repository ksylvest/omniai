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
    JSON_PROMPT = "Respond with valid JSON. Do not include any non-JSON in the response."

    # An error raised for tool-call issues.
    class ToolCallError < Error
      # @param tool_call [OmniAI::Chat::ToolCall]
      # @param message [String]
      def initialize(tool_call:, message:)
        super(message)
        @tool_call = tool_call
      end
    end

    # An error raised when a tool-call is missing.
    class ToolCallMissingError < ToolCallError
      def initialize(tool_call:)
        super(tool_call:, message: "missing tool for tool_call=#{tool_call.inspect}")
      end
    end

    module Role
      ASSISTANT = "assistant"
      USER = "user"
      SYSTEM = "system"
      TOOL = "tool"
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
    # @param format [:json, :text, OmniAI::Schema::Object, nil] optional
    #
    # @yield [prompt] optional
    # @yieldparam prompt [OmniAI::Chat::Prompt]
    #
    # @return [OmniAi::Chat]
    def initialize(prompt = nil, client:, model:, temperature: nil, stream: nil, tools: nil, format: nil, &block)
      raise ArgumentError, "prompt or block is required" if !prompt && !block

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
    # @raise [SSLError]
    #
    # @return [OmniAI::Chat::Response]
    def process!
      begin
        response = request!

        raise HTTPError, response.flush unless response.status.ok?

        completion = parse!(response:)
      rescue OpenSSL::SSL::SSLError => e
        raise SSLError, e.message, cause: e
      end

      if @tools && completion.tool_call_list?
        spawn!(
          @prompt.dup.tap do |prompt|
            prompt.messages += completion.messages
            prompt.messages += build_tool_call_messages(completion.tool_call_list)
          end
        ).process!
      else
        completion
      end
    end

  protected

    # @return [Boolean]
    def stream?
      !@stream.nil?
    end

    # Override  to provide a context (serializers / deserializes) for a provider.
    #
    # @return [Context, nil]
    def context
      nil
    end

    # @return [Logger, nil]
    def logger
      @client.logger
    end

    # Used to spawn another chat with the same configuration using different messages.
    #
    # @param prompt [OmniAI::Chat::Prompt]
    # @return [OmniAI::Chat]
    def spawn!(prompt)
      self.class.new(
        prompt,
        client: @client,
        model: @model,
        temperature: @temperature,
        stream: @stream,
        tools: @tools,
        format: @format
      )
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
    #
    # @raise [OmniAI::Chat::Error]
    #
    # @return [OmniAI::Chat::Response]
    def parse!(response:)
      if stream?
        stream!(response:)
      else
        complete!(response:)
      end
    end

    # @param response [HTTP::Response]
    #
    # @return [OmniAI::Chat::Response]
    def complete!(response:)
      OmniAI::Chat::Response.deserialize(response.parse, context:)
    end

    # @param response [HTTP::Response]
    #
    # @return [OmniAI::Chat::Response]
    def stream!(response:)
      raise Error, "#{self.class.name}#stream! unstreamable" unless @stream

      data = self.class::Stream.new(chunks: response.body, logger:).stream! do |chunk|
        case @stream
        when IO, StringIO
          if chunk.text?
            @stream << chunk.text
            @stream.flush
          end
        else @stream.call(chunk)
        end
      end

      response = OmniAI::Chat::Response.deserialize(data, context:)

      @stream.puts if response.text? && (@stream.is_a?(IO) || @stream.is_a?(StringIO))

      response
    end

    # @return [HTTP::Response]
    def request!
      logger&.debug("Chat#request! payload=#{payload.inspect}")

      @client
        .connection
        .accept(:json)
        .post(path, json: payload)
    end

    # @param tool_call_list [Array<OmniAI::Chat::ToolCall>]
    # @return [Array<Message>]
    def build_tool_call_messages(tool_call_list)
      tool_call_list.map do |tool_call|
        content = execute_tool_call(tool_call)
        ToolCallMessage.new(content:, tool_call_id: tool_call.id)
      end
    end

    # @raise [ToolCallError]
    # @param tool_call [OmniAI::Chat::ToolCall]
    # @return [ToolCallResult]
    def execute_tool_call(tool_call)
      logger&.debug("Chat#execute_tool_call tool_call=#{tool_call.inspect}")

      function = tool_call.function
      tool = @tools.find { |entry| function.name == entry.name } || raise(ToolCallMissingError, tool_call)
      content = tool.call(function.arguments)

      logger&.debug("Chat#execute_tool_call content=#{content.inspect}")

      content
    end
  end
end
