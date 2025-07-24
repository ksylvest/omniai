# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI threads implementation.
    class Thread
      HEADERS = { "OpenAI-Beta": "assistants=v2" }.freeze

      # @!attribute [rw] id
      #   @return [String, nil]
      attr_accessor :id

      # @!attribute [rw] metadata
      #   @return [Hash]
      attr_accessor :metadata

      # @!attribute [rw] tool_resources
      #   @return [Hash]
      attr_accessor :tool_resources

      # @!attribute [rw] deleted
      #   @return [Boolean, nil]
      attr_accessor :deleted

      # @param client [OmniAI::OpenAI::Client] optional
      # @param id [String]
      # @param metadata [String]
      def initialize(
        client: Client.new,
        id: nil,
        metadata: {},
        tool_resources: {}
      )
        @client = client
        @id = id
        @metadata = metadata
        @tool_resources = tool_resources
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} id=#{@id.inspect}>"
      end

      # @param id [String] required
      # @param client [OmniAI::OpenAI::Client] optional
      # @return [OmniAI::OpenAI::Thread]
      def self.find(id:, client: Client.new)
        response = client.connection
          .accept(:json)
          .headers(HEADERS)
          .get("/#{OmniAI::OpenAI::Client::VERSION}/threads/#{id}")

        raise HTTPError, response.flush unless response.status.ok?

        parse(data: response.parse)
      end

      # @param id [String] required
      # @param client [OmniAI::OpenAI::Client] optional
      # @return [Hash]
      def self.destroy!(id:, client: Client.new)
        response = client.connection
          .accept(:json)
          .headers(HEADERS)
          .delete("/#{OmniAI::OpenAI::Client::VERSION}/threads/#{id}")

        raise HTTPError, response.flush unless response.status.ok?

        response.parse
      end

      # @raise [HTTPError]
      # @return [OmniAI::OpenAI::Thread]
      def save!
        response = @client.connection
          .accept(:json)
          .headers(HEADERS)
          .post("/#{OmniAI::OpenAI::Client::VERSION}/threads#{"/#{@id}" if @id}", json: payload)
        raise HTTPError, response.flush unless response.status.ok?

        parse(data: response.parse)
        self
      end

      # @raise [OmniAI::Error]
      # @return [OmniAI::OpenAI::Thread]
      def destroy!
        raise OmniAI::Error, "cannot destroy a non-persisted thread" unless @id

        data = self.class.destroy!(id: @id, client: @client)
        @deleted = data["deleted"]
        self
      end

      # @return [OmniAI::OpenAI::Thread::Messages]
      def messages
        Messages.new(client: @client, thread: self)
      end

      # @return [OmniAI::OpenAI::Thread::Runs]
      def runs
        Runs.new(client: @client, thread: self)
      end

    private

      class << self
      private

        # @param data [Hash] required
        # @param client [OmniAI::OpenAI::Client] required
        # @return [OmniAI::OpenAI::Thread]
        def parse(data:, client: Client.new)
          new(
            client:,
            id: data["id"],
            metadata: data["metadata"],
            tool_resources: data["tool_resources"]
          )
        end
      end

      # @param data [Hash] required
      # @return [OmniAI::OpenAI::Thread]
      def parse(data:)
        @id = data["id"]
        @metadata = data["metadata"]
        @tool_resources = data["tool_resources"]
      end

      # @return [Hash]
      def payload
        {
          metadata: @metadata,
          tool_resources: @tool_resources,
        }.compact
      end
    end
  end
end
