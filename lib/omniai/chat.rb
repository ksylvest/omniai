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

    module Role
      ASSISTANT = 'assistant'
      USER = 'user'
      SYSTEM = 'system'
    end

    module Format
      JSON = :json
    end

    def self.process!(...)
      new(...).process!
    end

    # @param messages [String] required
    # @param client [OmniAI::Client] the client
    # @param model [String] required
    # @param temperature [Float, nil] optional
    # @param stream [Proc, IO, nil] optional
    # @param format [Symbol, nil] optional - :json
    def initialize(messages, client:, model:, temperature: nil, stream: nil, format: nil)
      @messages = arrayify(messages)
      @client = client
      @model = model
      @temperature = temperature
      @stream = stream
      @format = format
    end

    # @raise [HTTPError]
    def process!
      response = request!

      raise HTTPError, response.flush unless response.status.ok?

      parse!(response:)
    end

    protected

    # @return [Hash]
    def payload
      raise NotImplementedError, "#{self.class.name}#payload undefined"
    end

    # @return [String]
    def path
      raise NotImplementedError, "#{self.class.name}#path undefined"
    end

    # @param response [HTTP::Response]
    # @return [OmniAI::Chat::Completion]
    def parse!(response:)
      if @stream
        stream!(response:)
      else
        complete!(response:)
      end
    end

    # @param response [OmniAI::Chat::Completion]
    def complete!(response:)
      self.class::Completion.new(data: response.parse)
    end

    # @param response [HTTP::Response]
    # @return [OmniAI::Chat::Stream]
    def stream!(response:)
      raise Error, "#{self.class.name}#stream! unstreamable" unless @stream

      self.class::Stream.new(response:).stream! do |chunk|
        case @stream
        when IO, StringIO
          @stream << chunk.choice.delta.content
          @stream.flush
        else @stream.call(chunk)
        end
      end

      @stream.puts if @stream.is_a?(IO) || @stream.is_a?(StringIO)
    end

    # @return [Array<Hash>]
    def messages
      arrayify(@messages).map do |content|
        case content
        when String then { role: Role::USER, content: }
        when Hash then content
        else raise Error, "Unsupported content=#{content.inspect}"
        end
      end
    end

    # @param value [Object, Array<Object>]
    # @return [Array<Object>]
    def arrayify(value)
      value.is_a?(Array) ? value : [value]
    end

    # @return [HTTP::Response]
    def request!
      @client
        .connection
        .accept(:json)
        .post(path, json: payload)
    end
  end
end
