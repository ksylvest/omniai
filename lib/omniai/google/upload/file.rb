# frozen_string_literal: true

module OmniAI
  module Google
    class Upload
      # A file that can be used for generating chat completions.
      class File
        class DeleteError < HTTPError; end

        # @!attribute [rw] name
        #   @return [String]
        attr_accessor :name

        # @attribute [rw] uri
        #   @return [String]
        attr_accessor :uri

        # @attribute [rw] state
        #   @return [String]
        attr_accessor :state

        # @attribute [rw] mime_type
        #   @return [String]
        attr_accessor :mime_type

        # @param client [Client]
        # @param data [Hash]
        #
        # @return [File]
        def self.parse(client:, data:)
          new(
            client:,
            name: data["name"],
            uri: data["uri"],
            state: data["state"],
            mime_type: data["mimeType"]
          )
        end

        # @param client [Client]
        # @param name [String]
        # @param uri [String]
        # @param state [String]
        # @param mime_type [String]
        def initialize(client:, name:, uri:, state:, mime_type:)
          @client = client
          @name = name
          @uri = uri
          @state = state
          @mime_type = mime_type
        end

        # @raise [DeleteError]
        def delete!
          response = @client.connection
            .delete("/#{@client.version}/#{@name}", params: { key: @client.api_key })

          raise DeleteError, response unless response.status.success?
        end
      end
    end
  end
end
