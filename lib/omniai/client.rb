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
  #   end
  class Client
    class Error < StandardError; end

    attr_accessor :api_key, :logger, :host

    # @param api_key [String] optional
    # @param host [String] optional - supports for customzing the host of the client (e.g. 'http://localhost:8080')
    # @param logger [Logger] optional
    def initialize(api_key: nil, logger: nil, host: nil)
      @api_key = api_key
      @host = host
      @logger = logger
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
      raise NotImplementedError, "#{self.class.name}#connection undefined"
    end

    # @raise [OmniAI::Error]
    #
    # @param messages [String, Array, Hash]
    # @param model [String] optional
    # @param format [Symbol] optional :text or :json
    # @param temperature [Float, nil] optional
    # @param stream [Proc, nil] optional
    #
    # @return [OmniAI::Chat::Completion]
    def chat(messages, model:, temperature: nil, format: nil, stream: nil)
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
    # @return text [OmniAI::Transcribe::Transcription]
    def transcribe(io, model:, language: nil, prompt: nil, temperature: nil, format: nil)
      raise NotImplementedError, "#{self.class.name}#speak undefined"
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
    # @return [Tempfile``]
    def speak(input, model:, voice:, speed: nil, format: nil, &stream)
      raise NotImplementedError, "#{self.class.name}#speak undefined"
    end
  end
end
