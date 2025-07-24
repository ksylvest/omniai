# frozen_string_literal: true

module OmniAI
  module Google
    # Uploads a file to Google to be used when generating completions.
    class Upload
      class FetchError < HTTPError; end

      # @param client [Client]
      # @param io [IO]
      def self.process!(client:, io:)
        new(client:, io:).process!
      end

      # @param client [Client]
      # @param io [File]
      def initialize(client:, io:)
        @client = client
        @io = io
      end

      # @raise [HTTPError]
      #
      # @return [Upload::File]
      def process!
        response = io! do |io|
          response = @client
            .connection
            .headers({ "X-Goog-Upload-Protocol" => "raw" })
            .post("/upload/#{@client.version}/files",
              params: { key: @client.api_key }.compact,
              body: HTTP::FormData::File.new(io))
        end

        raise OmniAI::HTTPError, response.flush unless response.status.ok?

        File.parse(client: @client, data: response.parse["file"])
      end

    protected

      # @raise [FetchError]
      #
      # @yield [io]
      # @yieldparam io [IO]
      def io!(&block)
        case @io
        when File, IO then block.call(@io)
        else fetch!(&block)
        end
      end

      # @raise [FetchError]
      #
      # @yield [tempfile]
      # @yieldparam tempfile [Tempfile]
      def fetch!
        tempfile = Tempfile.new
        tempfile.binmode

        response = HTTP.follow.get(@io)
        raise FetchError, response.flush unless response.status.success?

        response.body.each { |chunk| tempfile.write(chunk) }
        tempfile.rewind

        yield(tempfile)
      ensure
        tempfile.close
        tempfile.unlink
      end
    end
  end
end
