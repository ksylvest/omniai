# frozen_string_literal: true

module OmniAI
  # An abstract class that must be subclassed (e.g. OmniAI::OpenAI::Client).
  #
  # Usage:
  #
  #   class OmniAI::OpenAI::Client < OmniAI::Client
  #     def initialize(api_key: ENV.fetch('OPENAI_API_KEY'), logger: nil)
  #       super
  #     end
  #
  #     # @return [HTTP::Client]
  #     def connection
  #       @connection ||= super.auth("Bearer: #{@api_key}")
  #     end
  #   end
  class Client
    # @!attribute [rw] api_key
    #   @return [String, nil]
    attr_accessor :api_key

    # @!attribute [rw] logger
    #   @return [Logger, nil]
    attr_accessor :logger

    # @!attribute [rw] host
    #   @return [String, nil]
    attr_accessor :host

    # @!attribute [rw] timeout
    #  @return [Integer, nil]
    attr_accessor :timeout

    # Initialize a client for Anthropic. This method requires the provider if it is undefined.
    #
    # @raise [OmniAI::LoadError] if the provider is not defined and the gem is not installed
    #
    # @return [Class<OmniAI::Client>]
    def self.anthropic
      require "omniai/anthropic" unless defined?(OmniAI::Anthropic::Client)
      OmniAI::Anthropic::Client
    rescue ::LoadError
      raise Error, "requires 'omniai-anthropic': `gem install omniai-anthropic`"
    end

    # Initialize a client for DeepSeek. This method requires the provider if it is undefined.
    #
    # @raise [OmniAI::LoadError] if the provider is not defined and the gem is not installed
    #
    # @return [Class<OmniAI::Client>]
    def self.deepseek
      require "omniai/deepseek" unless defined?(OmniAI::DeepSeek::Client)
      OmniAI::DeepSeek::Client
    rescue ::LoadError
      raise LoadError, "requires 'omniai-anthropic': `gem install omniai-anthropic`"
    end

    # Lookup the `OmniAI::Google::Client``. This method requires the provider if it is undefined.
    #
    # @raise [OmniAI::LoadError] if the provider is not defined and the gem is not installed
    #
    # @return [Class<OmniAI::Client>]
    def self.google
      require "omniai/google" unless defined?(OmniAI::Google::Client)
      OmniAI::Google::Client
    rescue ::LoadError
      raise Error, "requires 'omniai-google': `gem install omniai-google`"
    end

    # Initialize a client for Mistral. This method requires the provider if it is undefined.
    #
    # @raise [OmniAI::LoadError] if the provider is not defined and the gem is not installed
    #
    # @return [Class<OmniAI::Client>]
    def self.mistral
      require "omniai/mistral" unless defined?(OmniAI::Mistral::Client)
      OmniAI::Mistral::Client
    rescue ::LoadError
      raise Error, "requires 'omniai-mistral': `gem install omniai-mistral`"
    end

    # Initialize a client for OpenAI. This method requires the provider if it is undefined.
    #
    # @raise [OmniAI::Error] if the provider is not defined and the gem is not installed
    #
    # @return [Class<OmniAI::Client>]
    def self.openai
      require "omniai/openai" unless defined?(OmniAI::OpenAI::Client)
      OmniAI::OpenAI::Client
    rescue ::LoadError
      raise LoadError, "requires 'omniai-openai': `gem install omniai-openai`"
    end

    # Initialize a client by provider (e.g. 'openai'). This method attempts to require the provider.
    #
    # @raise [OmniAI::LoadError] if the provider is not defined and the gem is not installed
    #
    # @param provider [String, Symbol] required (e.g. 'anthropic', 'google', 'mistral', 'openai', etc)
    #
    # @return [OmniAI::Client]
    def self.find(provider:, **)
      klass =
        case provider
        when :anthropic, "anthropic" then anthropic
        when :deepseek, "deepseek" then deepseek
        when :google, "google" then google
        when :mistral, "mistral" then mistral
        when :openai, "openai" then openai
        else raise Error, "unknown provider=#{provider.inspect}"
        end

      klass.new(**)
    end

    # @param api_key [String, nil] optional
    # @param host [String, nil] optional - supports for customzing the host of the client (e.g. 'http://localhost:8080')
    # @param logger [Logger, nil] optional
    # @param timeout [Integer, nil] optional
    def initialize(api_key: nil, logger: nil, host: nil, timeout: nil)
      @api_key = api_key
      @host = host
      @logger = logger
      @timeout = timeout
    end

    # @return [String]
    def inspect
      props = []
      props << "api_key=#{masked_api_key.inspect}" if @api_key
      props << "host=#{@host.inspect}" if @host
      "#<#{self.class.name} #{props.join(' ')}>"
    end

    # @return [String]
    def masked_api_key
      "#{api_key[..2]}***" if api_key
    end

    # @return [HTTP::Client]
    def connection
      http = HTTP.persistent(@host)
      http = http.use(instrumentation: { instrumenter: Instrumentation.new(logger: @logger) }) if @logger
      http = http.timeout(@timeout) if @timeout
      http
    end

    # @raise [OmniAI::Error]
    #
    # @param messages [String] optional
    # @param model [String] optional
    # @param format [Symbol] optional :text or :json
    # @param temperature [Float, nil] optional
    # @param stream [Proc, nil] optional
    # @param tools [Array<OmniAI::Tool>] optional
    #
    # @yield [prompt] optional
    # @yieldparam prompt [OmniAI::Chat::Prompt]
    #
    # @return [OmniAI::Chat::Response]
    def chat(messages = nil, model:, temperature: nil, format: nil, stream: nil, tools: nil, &)
      raise NotImplementedError, "#{self.class.name}#chat undefined"
    end

    # @raise [OmniAI::Error]
    #
    # @param io [String, Pathname, IO] required
    # @param model [String]
    # @param language [String, nil] optional
    # @param prompt [String, nil] optional
    # @param temperature [Float, nil] optional
    # @param format [Symbol] :text, :srt, :vtt, or :json (default)
    #
    # @return [OmniAI::Transcribe::Transcription]
    def transcribe(io, model:, language: nil, prompt: nil, temperature: nil, format: nil)
      raise NotImplementedError, "#{self.class.name}#transcribe undefined"
    end

    # @raise [OmniAI::Error]
    #
    # @param input [String] required
    # @param model [String] required
    # @param voice [String] required
    # @param speed [Float] optional
    # @param format [String] optional (default "aac"):
    #   - "aac"
    #   - "mp3"
    #   - "flac"
    #   - "opus"
    #   - "pcm"
    #   - "wav"
    #
    # @yield [output] optional
    #
    # @return [Tempfile]
    def speak(input, model:, voice:, speed: nil, format: nil, &stream)
      raise NotImplementedError, "#{self.class.name}#speak undefined"
    end

    # @raise [OmniAI::Error]
    #
    # @param input [String] required
    # @param model [String] required
    #
    # @return [OmniAI::Embed::Embedding]
    def embed(input, model:)
      raise NotImplementedError, "#{self.class.name}#embed undefined"
    end
  end
end
