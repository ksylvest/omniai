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
    # @!attribute [rw] logger
    #   @return [Logger, nil]
    attr_accessor :logger

    # @!attribute [rw] host
    #   @return [String, nil]
    attr_accessor :host

    # @!attribute [rw] timeout
    #  @return [Integer, nil]
    attr_accessor :timeout

    # Discover a client by provider ('openai' then 'anthropic' then 'google' then 'mistral' then 'deepseek').
    #
    # @raise [OmniAI::LoadError] if no providers are installed
    #
    # @return [OmniAI::Client]
    def self.discover(**)
      %i[openai anthropic google mistral deepseek].each do |provider|
        return find(provider:, **)
      rescue LoadError
        next
      end

      raise LoadError, <<~TEXT
        Please run one of the following commands to install a provider specific gem:

          `gem install omniai-openai`
          `gem install omniai-anthropic`
          `gem install omniai-deepseek`
          `gem install omniai-llama`
          `gem install omniai-google`
          `gem install omniai-mistral`
      TEXT
    end

    # Initialize a client by provider (e.g. 'openai'). This method attempts to require the provider.
    #
    #
    # @param provider [String, Symbol] required (e.g. 'anthropic', 'deepseek', 'google', 'mistral', 'openai', 'llama')
    #
    # @raise [OmniAI::LoadError] if the provider is not defined and the gem is not installed
    #
    # @return [OmniAI::Client]
    def self.find(provider:, **)
      klass =
        case provider
        when :anthropic, "anthropic" then OmniAI::Anthropic::Client
        when :deepseek, "deepseek" then OmniAI::DeepSeek::Client
        when :google, "google" then OmniAI::Google::Client
        when :llama, "llama" then OmniAI::Llama::Client
        when :mistral, "mistral" then OmniAI::Mistral::Client
        when :openai, "openai" then OmniAI::OpenAI::Client
        else raise Error, "unknown provider=#{provider.inspect}"
        end

      klass.new(**)
    end

    # @param host [String] required
    # @param logger [Logger] optional (default: OmniAI.config.logger)
    # @param timeout [Integer] optional (default: OmniAI.config.timeout)
    def initialize(host:, logger: OmniAI.config.logger, timeout: OmniAI.config.timeout)
      @host = host
      @logger = logger
      @timeout = timeout
    end

    # @return [String]
    def inspect
      "#<#{self.class.name}>"
    end

    # @return [HTTP::Client]
    def connection
      http = HTTP.persistent(@host)
      http = http.use(instrumentation: { instrumenter: Instrumentation.new(logger: @logger) }) if @logger
      http.timeout(@timeout) if @timeout
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
    # @param format [String] 'text', 'srt', 'vtt', 'json' (default), or 'verbose_json'
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
