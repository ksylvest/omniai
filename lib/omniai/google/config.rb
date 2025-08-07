# frozen_string_literal: true

module OmniAI
  module Google
    # Configuration for Google.
    class Config
      module Version
        STABLE = "v1"
        BETA = "v1beta"
      end

      DEFAULT_HOST = "https://generativelanguage.googleapis.com"

      # @!attribute [rw] api_key
      #   @return [String]
      attr_accessor :api_key

      # @!attribute [rw] host
      #   @return [String]
      attr_accessor :host

      # @!attribute [rw] project_id
      #   @return [String, nil]
      attr_accessor :project_id

      # @!attribute [rw] location_id
      #   @return [String, nil]
      attr_accessor :location_id

      def initialize
        @host = ENV.fetch("GOOGLE_HOST", DEFAULT_HOST)
        @api_key = ENV.fetch("GOOGLE_API_KEY", nil)
        @project_id = ENV.fetch("GOOGLE_PROJECT_ID", nil)
        @location_id = ENV.fetch("GOOGLE_LOCATION_ID", nil)
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

      # @return [Boolean]
      def credentials?
        !!@credentials
      end
    end
  end
end
