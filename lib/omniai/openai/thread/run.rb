# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Thread
      # An OpenAI run within a thread.
      class Run
        module Status
          CANCELLED = "cancelled"
          FAILED = "failed"
          COMPLETED = "completed"
          EXPIRED = "expired"
        end

        TERMINATED_STATUSES = [
          Status::CANCELLED,
          Status::FAILED,
          Status::COMPLETED,
          Status::EXPIRED,
        ].freeze

        # @!attribute [rw] id
        #   @return [String, nil]
        attr_accessor :id

        # @!attribute [rw] assistant_id
        #   @return [String, nil]
        attr_accessor :assistant_id

        # @!attribute [rw] thread_id
        #   @return [String, nil]
        attr_accessor :thread_id

        # @!attribute [rw] status
        #   @return [String, nil]
        attr_accessor :status

        # @!attribute [rw] model
        #   @return [String, nil]
        attr_accessor :model

        # @!attribute [rw] temperature
        #   @return [Float, nil]
        attr_accessor :temperature

        # @!attribute [rw] instructions
        #   @return [String, nil]
        attr_accessor :instructions

        # @!attribute [rw] tools
        #   @return [Array<Hash>, nil]
        attr_accessor :tools

        # @!attribute [rw] metadata
        #   @return [Hash, nil]
        attr_accessor :metadata

        # @param id [String, nil] optional
        # @param assistant_id [String, nil] optional
        # @param thread_id [String, nil] optional
        # @param status [String, nil] optional
        # @param temperature [Decimal, nil] optional
        # @param instructions [String, nil] optional
        # @param metadata [Hash, nil] optional
        # @param tools [Array<Hash>, nil] optional
        # @param client [OmniAI::OpenAI::Client] optional
        def initialize(
          id: nil,
          assistant_id: nil,
          thread_id: nil,
          status: nil,
          model: nil,
          temperature: nil,
          instructions: nil,
          metadata: {},
          tools: [],
          client: Client.new
        )
          @id = id
          @assistant_id = assistant_id
          @thread_id = thread_id
          @status = status
          @model = model
          @temperature = temperature
          @instructions = instructions
          @metadata = metadata
          @tools = tools
          @client = client
        end

        # @return [String]
        def inspect
          props = [
            "id=#{@id.inspect}",
            ("assistant_id=#{@assistant_id.inspect}" if @assistant_id),
            ("thread_id=#{@thread_id.inspect}" if @thread_id),
            ("status=#{@status.inspect}" if @status),
          ].compact
          "#<#{self.class.name} #{props.join(' ')}>"
        end

        # @param thread_id [String] required
        # @param id [String] required
        # @param client [OmniAI::OpenAI::Client] optional
        # @return [OmniAI::OpenAI::Thread::Run]
        def self.find(thread_id:, id:, client: Client.new)
          response = client.connection
            .accept(:json)
            .headers(HEADERS)
            .get("/#{OmniAI::OpenAI::Client::VERSION}/threads/#{thread_id}/runs/#{id}")

          raise HTTPError, response.flush unless response.status.ok?

          parse(data: response.parse)
        end

        # @param thread_id [String] required
        # @param client [OmniAI::OpenAI::Client] optional
        # @return [Array<OmniAI::OpenAI::Thread::Run>]
        def self.all(thread_id:, limit: nil, client: Client.new)
          response = client.connection
            .accept(:json)
            .headers(HEADERS)
            .get("/#{OmniAI::OpenAI::Client::VERSION}/threads/#{thread_id}/runs", params: { limit: }.compact)

          raise HTTPError, response.flush unless response.status.ok?

          response.parse["data"].map { |data| parse(data:, client:) }
        end

        # @param thread_id [String] required
        # @param id [String] required
        # @param client [OmniAI::OpenAI::Client] optional
        # @return [Hash]
        def self.cancel!(thread_id:, id:, client: Client.new)
          response = client.connection
            .accept(:json)
            .headers(HEADERS)
            .post("/#{OmniAI::OpenAI::Client::VERSION}/threads/#{thread_id}/runs/#{id}/cancel")

          raise HTTPError, response.flush unless response.status.ok?

          response.parse
        end

        # @raise [HTTPError]
        # @return [OmniAI::OpenAI::Thread]
        def save!
          response = @client.connection
            .accept(:json)
            .headers(HEADERS)
            .post(path, json: payload)

          raise HTTPError, response.flush unless response.status.ok?

          parse(data: response.parse)
          self
        end

        # @raise [HTTPError]
        # @return [OmniAI::OpenAI::Thread]
        def reload!
          raise Error, "unable to fetch! without an ID" unless @id

          response = @client.connection
            .accept(:json)
            .headers(HEADERS)
            .get(path)

          raise HTTPError, response.flush unless response.status.ok?

          parse(data: response.parse)
          self
        end

        # @raise [OmniAI::Error]
        # @return [OmniAI::OpenAI::Thread]
        def cancel!
          raise OmniAI::Error, "cannot cancel a non-persisted thread" unless @id

          data = self.class.cancel!(thread_id: @thread_id, id: @id, client: @client)
          @status = data["status"]
          self
        end

        # @param delay [Numeric, nil] optional (seconds)
        #
        # @return [OmniAI::OpenAI::Thread::Run]
        def poll!(delay: 2)
          loop do
            reload!
            break if terminated?

            sleep(delay) if delay
          end
        end

        # @return [Boolean]
        def terminated?
          TERMINATED_STATUSES.include?(@status)
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
              assistant_id: data["assistant_id"],
              thread_id: data["thread_id"],
              status: data["status"],
              model: data["model"],
              temperature: data["temperature"],
              instructions: data["instructions"],
              tools: data["tools"],
              metadata: data["metadata"]
            )
          end
        end

        # @param data [Hash] required
        def parse(data:)
          @id = data["id"]
          @assistant_id = data["assistant_id"]
          @thread_id = data["thread_id"]
          @run_id = data["run_id"]
          @status = data["status"]
          @model = data["model"]
          @temperature = data["temperature"]
          @instructions = data["instructions"]
          @tools = data["tools"]
          @metadata = data["metadata"]
        end

        # @return [Hash]
        def payload
          {
            assistant_id: @assistant_id,
            model: @model,
            temperature: @temperature,
            instructions: @instructions,
            tools: @tools,
            metadata: @metadata,
          }.compact
        end

        # @return [String]
        def path
          "#{@client.api_prefix}/#{OmniAI::OpenAI::Client::VERSION}/threads/#{@thread_id}/runs#{"/#{@id}" if @id}"
        end
      end
    end
  end
end
