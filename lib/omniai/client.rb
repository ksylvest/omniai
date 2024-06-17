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

    attr_accessor :api_key

    # @param api_key [String]
    # @param logger [Logger]
    def initialize(api_key:, logger: nil)
      @api_key = api_key
      @logger = logger
    end

    # @return [String]
    def inspect
      masked_api_key = "#{api_key[..2]}***" if api_key
      "#<#{self.class.name} api_key=#{masked_api_key.inspect}>"
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
    # @param file [IO]
    # @param model [String]
    # @param language [String, nil] optional
    # @param prompt [String, nil] optional
    # @param temperature [Float, nil] optional
    # @param format [Symbol] :text, :srt, :vtt, or :json (default)
    #
    # @return text [OmniAI::Transcribe::Transcription]
    def transcribe(file, model:, language: nil, prompt: nil, temperature: nil, format: nil)
      raise NotImplementedError, "#{self.class.name}#speak undefined"
    end
  end
end
