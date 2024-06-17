# frozen_string_literal: true

module OmniAI
  # An abstract class that provides a consistent interface for processing transcribe requests.
  #
  # Usage:
  #
  #   class OmniAI::OpenAI::Transcribe < OmniAI::Transcribe
  #     module Model
  #       WHISPER_1 = "whisper-1"
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
  #   client.transcribe(File.open("..."), model: "...", format: :json)
  class Transcribe
    module Language
      AFRIKAANS = 'af'
      ARABIC = 'ar'
      ARMENIAN = 'hy'
      AZERBAIJANI = 'az'
      BELARUSIAN = 'be'
      BOSNIAN = 'bs'
      BULGARIAN = 'bg'
      CATALAN = 'ca'
      CHINESE = 'zh'
      CROATIAN = 'hr'
      CZECH = 'cs'
      DANISH = 'da'
      DUTCH = 'nl'
      ENGLISH = 'en'
      ESTONIAN = 'et'
      FINNISH = 'fi'
      FRENCH = 'fr'
      GALICIAN = 'gl'
      GERMAN = 'de'
      GREEK = 'el'
      HEBREW = 'he'
      HINDI = 'hi'
      HUNGARIAN = 'hu'
      ICELANDIC = 'is'
      INDONESIAN = 'id'
      ITALIAN = 'it'
      JAPANESE = 'ja'
      KANNADA = 'kn'
      KAZAKH = 'kk'
      KOREAN = 'ko'
      LATVIAN = 'lv'
      LITHUANIAN = 'lt'
      MACEDONIAN = 'mk'
      MALAY = 'ms'
      MARATHI = 'mr'
      MAORI = 'mi'
      NEPALI = 'ne'
      NORWEGIAN = 'no'
      PERSIAN = 'fa'
      POLISH = 'pl'
      PORTUGUESE = 'pt'
      ROMANIAN = 'ro'
      RUSSIAN = 'ru'
      SERBIAN = 'sr'
      SLOVAK = 'sk'
      SLOVENIAN = 'sl'
      SPANISH = 'es'
      SWAHILI = 'sw'
      SWEDISH = 'sv'
      TAGALOG = 'tl'
      TAMIL = 'ta'
      THAI = 'th'
      TURKISH = 'tr'
      UKRAINIAN = 'uk'
      URDU = 'ur'
      VIETNAMESE = 'vi'
      WELSH = 'cy'
    end

    module Format
      JSON = 'json'
      TEXT = 'text'
      VTT = 'vtt'
      SRT = 'srt'
    end

    def self.process!(...)
      new(...).process!
    end

    # @param path [String] required
    # @param client [OmniAI::Client] the client
    # @param model [String] required
    # @param language [String, nil] optional
    # @param prompt [String, nil] optional
    # @param temperature [Float, nil] optional
    # @param format [String, nil] optional
    def initialize(path, client:, model:, language: nil, prompt: nil, temperature: nil, format: Format::JSON)
      @path = path
      @model = model
      @language = language
      @prompt = prompt
      @temperature = temperature
      @format = format
      @client = client
    end

    # @return [OmniAI::Transcribe::Transcription]
    # @raise [ExecutionError]
    def process!
      response = request!
      raise HTTPError, response.flush unless response.status.ok?

      data = @format.nil? || @format.eql?(Format::JSON) ? response.parse : { text: String(response.body) }
      Transcription.new(format: @format, data:)
    end

    protected

    # @return [Hash]
    def payload
      {
        file: HTTP::FormData::File.new(@path),
        model: @model,
        language: @language,
        prompt: @prompt,
        temperature: @temperature,
      }.compact
    end

    # @return [String]
    def path
      raise NotImplementedError, "#{self.class.name}#path undefined"
    end

    # @return [HTTP::Response]
    def request!
      @client
        .connection
        .accept(@format.eql?(Format::JSON) ? :json : :text)
        .post(path, form: payload)
    end
  end
end
