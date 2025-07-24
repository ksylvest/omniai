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
      # @!attribute [rw] version
      #   @return [String, nil]
      attr_accessor :version

      # @param api_key [String] default is `OmniAI::Google.config.api_key`
      # @param project_id [String] default is `OmniAI::Google.config.project_id`
      # @param location_id [String] default is `OmniAI::Google.config.location_id`
      # @param credentials [Google::Auth::ServiceAccountCredentials] default is `OmniAI::Google.config.credentials`
      # @param host [String] default is `OmniAI::Google.config.host`
      # @param version [String] default is `OmniAI::Google.config.version`
      # @param logger [Logger] default is `OmniAI::Google.config.logger`
      # @param timeout [Integer] default is `OmniAI::Google.config.timeout`
      def initialize(
        api_key: OmniAI::Google.config.api_key,
        project_id: OmniAI::Google.config.project_id,
        location_id: OmniAI::Google.config.location_id,
        credentials: OmniAI::Google.config.credentials,
        logger: OmniAI::Google.config.logger,
        host: OmniAI::Google.config.host,
        version: OmniAI::Google.config.version,
        timeout: OmniAI::Google.config.timeout
      )
        if api_key.nil? && credentials.nil?
          raise(ArgumentError, "either an `api_key` or `credentials` must be provided")
        end

        super(api_key:, host:, logger:, timeout:)

        @project_id = project_id
        @location_id = location_id
        @credentials = Credentials.parse(credentials)
        @version = version
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
        http = super
        http = http.auth(auth) if credentials?
        http
      end

      # @return [Boolean]
      def credentials?
        !@credentials.nil?
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
