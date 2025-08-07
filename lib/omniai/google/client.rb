# frozen_string_literal: true

module OmniAI
  module Google
    # A Google client implementation. Usage:
    #
    # w/ `api_key``:
    #   client = OmniAI::Google::Client.new(api_key: '...')
    #
    # w/ ENV['GOOGLE_API_KEY']:
    #
    #   ENV['GOOGLE_API_KEY'] = '...'
    #   client = OmniAI::Google::Client.new
    #
    # w/ config:
    #
    #   OmniAI::Google.configure do |config|
    #     config.api_key = '...'
    #   end
    #
    #   client = OmniAI::Google::Client.new
    class Client < OmniAI::Client
      # @!attribute [rw] String
      #   @return [String]
      attr_accessor :api_key

      # @!attribute [rw] project_id
      #   @return [String, nil]
      attr_accessor :project_id

      # @!attribute [rw] location_id
      #   @return [String, nil]
      attr_accessor :location_id

      # @!attribute [rw] version
      #   @return [String, nil]
      attr_accessor :version

      # @param host [String] optional (default: OmniAI.config.google.host)
      # @param api_key [String] optional (default: OmniAI.config.google.api_key)
      # @param logger [Logger] optional (default: OmniAI.config.logger)
      # @param timeout [Integer] optional (default: OmniAI.config.timeout)
      # @param project_id [String] optional (default: OmniAI.config.google.project_id)
      # @param location_id [String] optional (default: OmniAI.config.google.location_id)
      # @param version [String] optional (default: OmniAI.config.google.version)
      # @param credentials [Google::Auth::Credentials] optional (default: OmniAI.config.google.credentials)
      def initialize(
        host: OmniAI.config.google.host,
        api_key: OmniAI.config.google.api_key,
        logger: OmniAI.config.logger,
        timeout: OmniAI.config.timeout,
        project_id: OmniAI.config.google.project_id,
        location_id: OmniAI.config.google.location_id,
        version: OmniAI.config.google.version,
        credentials: OmniAI.config.google.credentials
      )
        super(host:, logger:, timeout:)
        @api_key = api_key
        @project_id = project_id
        @location_id = location_id
        @version = version
        @credentials = credentials
      end

      # @raise [OmniAI::Error]
      #
      # @param messages [String] optional
      # @param model [String] optional
      # @param format [Symbol] optional :text or :json
      # @param temperature [Float, nil] optional
      # @param stream [Proc, nil] optional
      # @param tools [Array<OmniAI::Chat::Tool>, nil] optional
      #
      # @yield [prompt] optional
      # @yieldparam prompt [OmniAI::Chat::Prompt]
      #
      # @return [OmniAI::Chat::Completion]
      def chat(messages = nil, model: Chat::DEFAULT_MODEL, temperature: nil, format: nil, stream: nil, tools: nil, &)
        Chat.process!(messages, model:, temperature:, format:, stream:, tools:, client: self, &)
      end

      # @param io [File, String] required - a file or URL
      #
      # @raise [OmniAI::Google::Upload::FetchError]
      #
      # @return [OmniAI::Google::Upload::File]
      def upload(io)
        Upload.process!(client: self, io:)
      end

      # @raise [OmniAI::Error]
      #
      # @param input [String, Array<String>, Array<Integer>] required
      # @param model [String] optional
      def embed(input, model: Embed::DEFAULT_MODEL)
        Embed.process!(input, model:, client: self)
      end

      # @raise [OmniAI::Error]
      #
      # @param input [String, File, IO] required - audio file path, file object, or GCS URI
      # @param model [String] optional
      # @param language [String, Array<String>] optional - language codes for transcription
      # @param format [Symbol] optional - :json or :verbose_json
      def transcribe(input, model: Transcribe::DEFAULT_MODEL, language: nil, format: nil)
        Transcribe.process!(input, model:, language:, format:, client: self)
      end

      # @return [String]
      def path
        if @project_id && @location_id
          "/#{@version}/projects/#{@project_id}/locations/#{@location_id}/publishers/google"
        else
          "/#{@version}"
        end
      end

      # @return [HTTP::Client]
      def connection
        @connection ||= begin
          http = super
          http = http.auth(auth) if credentials?
          http
        end
      end

      # @return [Boolean]
      def credentials?
        !!@credentials
      end

      # @return [Boolean]
      def vertex?
        @host.include?("aiplatform.googleapis.com")
      end

    private

      # @return [String] e.g. "Bearer ..."
      def auth
        @credentials.fetch_access_token!
        "Bearer #{@credentials.access_token}"
      end
    end
  end
end
