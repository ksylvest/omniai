# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI assistants implementation.
    class Assistant
      HEADERS = { "OpenAI-Beta": "assistants=v2" }.freeze

      # @!attribute [rw] id
      #   @return [String, nil]
      attr_accessor :id

      # @!attribute [rw] name
      #   @return [String, nil]
      attr_accessor :name

      # @!attribute [rw] model
      #   @return [String, nil]
      attr_accessor :model

      # @!attribute [rw] description
      #   @return [String, nil]
      attr_accessor :description

      # @!attribute [rw] instructions
      # @return [String, nil]
      attr_accessor :instructions

      # @!attribute [rw] metadata
      #   @return [Hash]
      attr_accessor :metadata

      # @!attribute [rw] deleted
      #   @return [Boolean, nil]
      attr_accessor :deleted

      # @!attribute [r] tools
      #   @return [Array<Hash>, nil]
      attr_accessor :tools

      # @param client [OmniAI::OpenAI::Client] optional
      # @param id [String]
      # @param name [String]
      # @param model [String]
      # @param description [String, nil] optional
      # @param instructions [String,nil] optional
      # @param metadata [Hash] optional
      def initialize(
        client: Client.new,
        id: nil,
        name: nil,
        model: OmniAI::Chat::DEFAULT_MODEL,
        description: nil,
        instructions: nil,
        metadata: {},
        tools: []
      )
        @client = client
        @id = id
        @name = name
        @model = model
        @description = description
        @instructions = instructions
        @metadata = metadata
        @tools = tools
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} id=#{@id.inspect} name=#{@name.inspect} model=#{@model.inspect}>"
      end

      # @param id [String] required
      # @param client [OmniAI::OpenAI::Client] optional
      # @return [OmniAI::OpenAI::Assistant]
      def self.find(id:, client: Client.new)
        response = client.connection
          .accept(:json)
          .headers(HEADERS)
          .get("/#{OmniAI::OpenAI::Client::VERSION}/assistants/#{id}")

        raise HTTPError, response.flush unless response.status.ok?

        parse(data: response.parse)
      end

      # @param limit [Integer] optional
      # @param client [OmniAI::OpenAI::Client] optional
      # @return [Array<OmniAI::OpenAI::Assistant>]
      def self.all(limit: nil, client: Client.new)
        response = client.connection
          .accept(:json)
          .headers(HEADERS)
          .get("/#{OmniAI::OpenAI::Client::VERSION}/assistants", params: { limit: }.compact)

        raise HTTPError, response.flush unless response.status.ok?

        response.parse["data"].map { |data| parse(data:, client:) }
      end

      # @param id [String] required
      # @param client [OmniAI::OpenAI::Client] optional
      # @return [void]
      def self.destroy!(id:, client: Client.new)
        response = client.connection
          .accept(:json)
          .headers(HEADERS)
          .delete("/#{OmniAI::OpenAI::Client::VERSION}/assistants/#{id}")

        raise HTTPError, response.flush unless response.status.ok?

        response.parse
      end

      # @raise [HTTPError]
      # @return [OmniAI::OpenAI::Assistant]
      def save!
        response = @client.connection
          .accept(:json)
          .headers(HEADERS)
          .post("/#{OmniAI::OpenAI::Client::VERSION}/assistants#{"/#{@id}" if @id}", json: payload)
        raise HTTPError, response.flush unless response.status.ok?

        parse(data: response.parse)
        self
      end

      # @raise [OmniAI::Error]
      # @return [OmniAI::OpenAI::Assistant]
      def destroy!
        raise OmniAI::Error, "cannot destroy a non-persisted assistant" unless @id

        data = self.class.destroy!(id: @id, client: @client)
        @deleted = data["deleted"]
        self
      end

    private

      class << self
      private

        # @param data [Hash] required
        # @param client [OmniAI::OpenAI::Client] required
        # @return [OmniAI::OpenAI::Assistant]
        def parse(data:, client: Client.new)
          new(
            client:,
            id: data["id"],
            name: data["name"],
            model: data["model"],
            description: data["description"],
            instructions: data["instructions"],
            metadata: data["metadata"],
            tools: data["tools"]
          )
        end
      end

      # @param data [Hash] required
      # @return [OmniAI::OpenAI::Assistant]
      def parse(data:)
        @id = data["id"]
        @name = data["name"]
        @model = data["model"]
        @description = data["description"]
        @instructions = data["instructions"]
        @metadata = data["metadata"]
        @tools = data["tools"]
      end

      # @return [Hash]
      def payload
        {
          name: @name,
          model: @model,
          description: @description,
          instructions: @instructions,
          metadata: @metadata,
          tools: @tools,
        }.compact
      end
    end
  end
end
