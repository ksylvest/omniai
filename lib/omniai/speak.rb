# frozen_string_literal: true

module OmniAI
  # An abstract class that provides a consistent interface for processing speak requests.
  #
  # Usage:
  #
  #   class OmniAI::OpenAI::Speak < OmniAI::Speakw
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
  class Speak
    module Format
      AAC = "aac"
      FLAC = "flac"
      MP3 = "mp3"
      OPUS = "opus"
      PCM = "pcm"
      WAV = "wav"
    end

    # @raise [HTTPError]
    #
    # @param client [OmniAI::Client] required
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
    # @yield [chunk]
    #
    # @return [Tempfile]
    def self.process!(input, client:, model:, voice:, speed: nil, format: nil, &)
      new(input, client:, model:, voice:, speed:, format:).process!(&)
    end

    # @param client [OmniAI::Client] required
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
    def initialize(input, client:, model:, voice:, speed: nil, format: nil)
      @input = input
      @client = client
      @model = model
      @voice = voice
      @speed = speed
      @format = format
    end

    # @raise [HTTPError]
    #
    # @yield [chunk]
    #
    # @return [Tempfile]
    def process!(&block)
      response = request!

      raise HTTPError, response.flush unless response.status.ok?

      if block
        stream!(response:, &block)
      else
        fetch!(response:)
      end
    end

  protected

    # @param response [HTTP::Response]
    #
    # @yield [chunk]
    def stream!(response:, &block)
      response.body.each { |chunk| block.call(chunk) }
    end

    # @param response [HTTP::Response]
    #
    # @return [Tempfile]
    def fetch!(response:)
      tempfile = Tempfile.new
      tempfile.binmode
      response.body.each { |chunk| tempfile << chunk }
      tempfile.rewind
      tempfile
    end

    # @return [Hash]
    def payload
      {
        model: @model,
        voice: @voice,
        input: @input,
        speed: @speed,
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
        .post(path, json: payload)
    end
  end
end
