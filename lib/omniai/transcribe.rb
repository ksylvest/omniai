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
  #   File.open('audio.wav', 'rb') do |file|
  #     client.transcribe(file, model: "...", format: :json)
  #   end
  class Transcribe
    module Language
      AFRIKAANS = "af"
      ARABIC = "ar"
      ARMENIAN = "hy"
      AZERBAIJANI = "az"
      BELARUSIAN = "be"
      BOSNIAN = "bs"
      BULGARIAN = "bg"
      CATALAN = "ca"
      CHINESE = "zh"
      CROATIAN = "hr"
      CZECH = "cs"
      DANISH = "da"
      DUTCH = "nl"
      ENGLISH = "en"
      ESTONIAN = "et"
      FINNISH = "fi"
      FRENCH = "fr"
      GALICIAN = "gl"
      GERMAN = "de"
      GREEK = "el"
      HEBREW = "he"
      HINDI = "hi"
      HUNGARIAN = "hu"
      ICELANDIC = "is"
      INDONESIAN = "id"
      ITALIAN = "it"
      JAPANESE = "ja"
      KANNADA = "kn"
      KAZAKH = "kk"
      KOREAN = "ko"
      LATVIAN = "lv"
      LITHUANIAN = "lt"
      MACEDONIAN = "mk"
      MALAY = "ms"
      MARATHI = "mr"
      MAORI = "mi"
      NEPALI = "ne"
      NORWEGIAN = "no"
      PERSIAN = "fa"
      POLISH = "pl"
      PORTUGUESE = "pt"
      ROMANIAN = "ro"
      RUSSIAN = "ru"
      SERBIAN = "sr"
      SLOVAK = "sk"
      SLOVENIAN = "sl"
      SPANISH = "es"
      SWAHILI = "sw"
      SWEDISH = "sv"
      TAGALOG = "tl"
      TAMIL = "ta"
      THAI = "th"
      TURKISH = "tr"
      UKRAINIAN = "uk"
      URDU = "ur"
      VIETNAMESE = "vi"
      WELSH = "cy"
    end

    module Format
      JSON = "json"
      TEXT = "text"
      VTT = "vtt"
      SRT = "srt"
      VERBOSE_JSON = "verbose_json"
    end

    def self.process!(...)
      new(...).process!
    end

    # @param io [String, Pathname, IO] required
    # @param client [OmniAI::Client] the client
    # @param model [String] required
    # @param language [String, nil] optional
    # @param prompt [String, nil] optional
    # @param temperature [Float, nil] optional
    # @param format [String, nil] optional
    def initialize(io, client:, model:, language: nil, prompt: nil, temperature: nil, format: nil)
      @io = io
      @client = client
      @model = model
      @language = language
      @prompt = prompt
      @temperature = temperature
      @format = format || Format::JSON
    end

    # @raise [HTTPError]
    #
    # @return [OmniAI::Transcribe::Transcription]
    def process!
      response = request!
      raise HTTPError, response.flush unless response.status.ok?

      data = json? || verbose_json? ? response.parse : String(response.body)

      Transcription.parse(model: @model, format: @format, data:)
    end

  protected

    # @return [Boolean]
    def json?
      String(@format).eql?(Format::JSON)
    end

    # @return [Boolean]
    def verbose_json?
      String(@format).eql?(Format::VERBOSE_JSON)
    end

    # @return [Hash]
    def payload
      {
        file: HTTP::FormData::File.new(@io),
        model: @model,
        language: @language,
        prompt: @prompt,
        temperature: @temperature,
        response_format: @format,
        timestamp_granularities: verbose_json? ? %w[segment] : nil,
      }.compact
    end

  private

    # @return [String]
    def path
      raise NotImplementedError, "#{self.class.name}#path undefined"
    end

    # @return [HTTP::Response]
    def request!
      @client
        .connection
        .accept(json? || verbose_json? ? :json : :text)
        .post(path, form: payload)
    end
  end
end
