# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI file implementation.
    class File
      # @!attribute [rw] id
      #   @return [String, nil]
      attr_accessor :id

      # @!attribute [rw] bytes
      #   @return [Integer, nil]
      attr_accessor :bytes

      # @!attribute [rw] filename
      #   @return [String, nil]
      attr_accessor :filename

      # @!attribute [rw] purpose
      #   @return [String, nil]
      attr_accessor :purpose

      # @!attribute [rw] deleted
      #   @return [Boolean, nil]
      attr_accessor :deleted

      module Purpose
        ASSISTANTS = "assistants"
      end

      # @param client [OmniAI::OpenAI::Client] optional
      # @param io [IO] optional
      # @param id [String] optional
      # @param bytes [Integer] optional
      # @param filename [String] optional
      # @param purpose [String] optional
      def initialize(
        client: Client.new,
        io: nil,
        id: nil,
        bytes: nil,
        filename: nil,
        purpose: Purpose::ASSISTANTS
      )
        @client = client
        @io = io
        @id = id
        @bytes = bytes
        @filename = filename
        @purpose = purpose
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} id=#{@id.inspect} filename=#{@filename.inspect}>"
      end

      # @raise [OmniAI::Error]
      # @yield [String]
      def content(&)
        raise OmniAI::Error, "cannot fetch content without ID" unless @id

        response = @client.connection
          .get("/#{OmniAI::OpenAI::Client::VERSION}/files/#{@id}/content")

        raise HTTPError, response.flush unless response.status.ok?

        response.body.each(&)
      end

      # @param id [String] required
      # @param client [OmniAI::OpenAI::Client] optional
      # @return [OmniAI::OpenAI::Assistant]
      def self.find(id:, client: Client.new)
        response = client.connection
          .accept(:json)
          .get("/#{OmniAI::OpenAI::Client::VERSION}/files/#{id}")

        raise HTTPError, response.flush unless response.status.ok?

        parse(data: response.parse)
      end

      # @param client [OmniAI::OpenAI::Client] optional
      # @return [Array<OmniAI::OpenAI::File>]
      def self.all(client: Client.new)
        response = client.connection
          .accept(:json)
          .get("/#{OmniAI::OpenAI::Client::VERSION}/files")

        raise HTTPError, response.flush unless response.status.ok?

        response.parse["data"].map { |data| parse(data:, client:) }
      end

      # @param id [String] required
      # @param client [OmniAI::OpenAI::Client] optional
      # @return [Hash]
      def self.destroy!(id:, client: Client.new)
        response = client.connection
          .accept(:json)
          .delete("/#{OmniAI::OpenAI::Client::VERSION}/files/#{id}")

        raise HTTPError, response.flush unless response.status.ok?

        response.parse
      end

      # @raise [HTTPError]
      # @return [OmniAI::OpenAI::Assistant]
      def save!
        raise OmniAI::Error, "cannot save a file without IO" unless @io

        response = @client.connection
          .accept(:json)
          .post("/#{OmniAI::OpenAI::Client::VERSION}/files", form: payload)
        raise HTTPError, response.flush unless response.status.ok?

        parse(data: response.parse)
        self
      end

      # @raise [OmniAI::Error]
      # @return [OmniAI::OpenAI::Assistant]
      def destroy!
        raise OmniAI::Error, "cannot destroy w/o ID" unless @id

        data = self.class.destroy!(id: @id, client: @client)
        @deleted = data["deleted"]
        self
      end

    private

      # @return [Hash]
      def payload
        {
          file: HTTP::FormData::File.new(@io),
          purpose: @purpose,
        }
      end

      class << self
      private

        # @param data [Hash] required
        # @param client [OmniAI::OpenAI::Client] required
        # @return [OmniAI::OpenAI::Assistant]
        def parse(data:, client: Client.new)
          new(
            client:,
            id: data["id"],
            bytes: data["bytes"],
            filename: data["filename"],
            purpose: data["purpose"]
          )
        end
      end

      # @param data [Hash] required
      # @return [OmniAI::OpenAI::Assistant]
      def parse(data:)
        @id = data["id"]
        @bytes = data["bytes"]
        @filename = data["filename"]
        @purpose = data["purpose"]
      end
    end
  end
end
