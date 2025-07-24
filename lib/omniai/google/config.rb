# frozen_string_literal: true

module OmniAI
  module Google
    # Configuration for Google.
    class Config < OmniAI::Config
      module Version
        STABLE = "v1"
        BETA = "v1beta"
      end

      DEFAULT_HOST = "https://generativelanguage.googleapis.com"

      # @!attribute [rw] project_id
      #   @return [String, nil]
      attr_accessor :project_id

      # @!attribute [rw] location_id
      #   @return [String, nil]
      attr_accessor :location_id

      # @param api_key [String, nil] optional - defaults to `ENV['GOOGLE_API_KEY']`
      # @param project_id [String, nil] optional - defaults to `ENV['GOOGLE_PROJECT_ID']`
      # @param location_id [String, nil] optional - defaults to `ENV['GOOGLE_LOCATION_ID']`
      # @param host [String, nil] optional - defaults to `ENV['GOOGLE_HOST'] w/ fallback to `DEFAULT_HOST`
      # @param version [String, nil] optional - defaults to `ENV['GOOGLE_VERSION'] w/ fallback to `DEFAULT_VERSION`
      # @param logger [Logger, nil] optional
      # @param timeout [Integer, Hash, nil] optional
      def initialize(
        api_key: ENV.fetch("GOOGLE_API_KEY", nil),
        project_id: ENV.fetch("GOOGLE_PROJECT_ID", nil),
        location_id: ENV.fetch("GOOGLE_LOCATION_ID", nil),
        host: ENV.fetch("GOOGLE_HOST", DEFAULT_HOST),
        logger: nil,
        timeout: nil
      )
        super(api_key:, host:, logger:, timeout:)
        @project_id = project_id
        @location_id = location_id
      end

      # @return [String]
      def version
        @host.eql?(DEFAULT_HOST) ? Version::BETA : Version::STABLE
      end

      # @return [Google::Auth::ServiceAccountCredentials, nil]
      def credentials
        return @credentials if defined?(@credentials)

        Credentials.detect
      end

      # @param value [String, File, Hash, Google::Auth::ServiceAccountCredentials, nil]
      def credentials=(value)
        @credentials = Credentials.parse(value)
      end
    end
  end
end
