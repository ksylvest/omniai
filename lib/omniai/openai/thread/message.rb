# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Thread
      # An OpenAI message within a thread.
      class Message
        # @!attribute [rw] id
        #   @return [String, nil]
        attr_accessor :id

        # @!attribute [rw] assistant_id
        #   @return [String, nil]
        attr_accessor :assistant_id

        # @!attribute [rw] thread_id
        #   @return [String, nil]
        attr_accessor :thread_id

        # @!attribute [rw] run_id
        #   @return [String, nil]
        attr_accessor :run_id

        # @!attribute [rw] role
        #   @return [String, nil]
        attr_accessor :role

        # @!attribute [rw] content
        #   @return [String, Array, nil]
        attr_accessor :content

        # @!attribute [rw] attachments
        #   @return [Array, nil]
        attr_accessor :attachments

        # @!attribute [rw] metadata
        #   @return [Array, nil]
        attr_accessor :metadata

        # @!attribute [rw] deleted
        #   @return [Boolean, nil]
        attr_accessor :deleted

        # @param id [String, nil] optional
        # @param assistant_id [String, nil] optional
        # @param thread_id [String, nil] optional
        # @param run_id [String, nil] optional
        # @param role [String, nil] optional
        # @param content [String, Array, nil] optional
        # @param attachments [Array, nil] optional
        # @param metadata [Hash, nil] optional
        # @param client [OmniAI::OpenAI::Client] optional
        def initialize(
          id: nil,
          assistant_id: nil,
          thread_id: nil,
          run_id: nil,
          role: nil,
          content: nil,
          attachments: [],
          metadata: {},
          client: Client.new
        )
          @id = id
          @assistant_id = assistant_id
          @thread_id = thread_id
          @run_id = run_id
          @role = role
          @content = content
          @attachments = attachments
          @metadata = metadata
          @client = client
        end

        # @return [String]
        def inspect
          props = [
            "id=#{@id.inspect}",
            ("assistant_id=#{@assistant_id.inspect}" if @assistant_id),
            ("thread_id=#{@thread_id.inspect}" if @thread_id),
            ("content=#{@content.inspect}" if @content),
          ].compact

          "#<#{self.class.name} #{props.join(' ')}>"
        end

        # @param thread_id [String] required
        # @param id [String] required
        # @param client [OmniAI::OpenAI::Client] optional
        # @return [OmniAI::OpenAI::Thread::Message]
        def self.find(thread_id:, id:, client: Client.new)
          response = client.connection
            .accept(:json)
            .headers(HEADERS)
            .get("/#{OmniAI::OpenAI::Client::VERSION}/threads/#{thread_id}/messages/#{id}")

          raise HTTPError, response.flush unless response.status.ok?

          parse(data: response.parse)
        end

        # @param thread_id [String] required
        # @param client [OmniAI::OpenAI::Client] optional
        # @return [Array<OmniAI::OpenAI::Thread::Message>]
        def self.all(thread_id:, limit: nil, client: Client.new)
          response = client.connection
            .accept(:json)
            .headers(HEADERS)
            .get("/#{OmniAI::OpenAI::Client::VERSION}/threads/#{thread_id}/messages", params: { limit: }.compact)

          raise HTTPError, response.flush unless response.status.ok?

          response.parse["data"].map { |data| parse(data:, client:) }
        end

        # @param thread_id [String] required
        # @param id [String] required
        # @param client [OmniAI::OpenAI::Client] optional
        # @return [Hash]
        def self.destroy!(thread_id:, id:, client: Client.new)
          response = client.connection
            .accept(:json)
            .headers(HEADERS)
            .delete("/#{OmniAI::OpenAI::Client::VERSION}/threads/#{thread_id}/messages/#{id}")

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

        # @raise [OmniAI::Error]
        # @return [OmniAI::OpenAI::Thread]
        def destroy!
          raise OmniAI::Error, "cannot destroy a non-persisted thread" unless @id

          data = self.class.destroy!(thread_id: @thread_id, id: @id, client: @client)
          @deleted = data["deleted"]
          self
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
              run_id: data["run_id"],
              role: data["role"],
              content: Content.for(data: data["content"], client:),
              attachments: Attachment.for(data: data["attachments"], client:),
              metadata: data["metadata"]
            )
          end
        end

        # @param data [Hash] required
        def parse(data:)
          @id = data["id"]
          @assistant_id = data["assistant_id"]
          @thread_id =  data["thread_id"]
          @run_id =  data["run_id"]
          @role = data["role"]
          @content = Content.for(data: data["content"], client: @client)
          @attachments = Attachment.for(data: data["content"], client: @client)
          @metadata =  data["metadata"]
        end

        # @return [Hash]
        def payload
          {
            role: @role,
            content: @content,
            attachments: @attachments,
            metadata: @metadata,
          }.compact
        end

        # @return [String]
        def path
          "#{@client.api_prefix}/#{OmniAI::OpenAI::Client::VERSION}/threads/#{@thread_id}/messages#{"/#{@id}" if @id}"
        end
      end
    end
  end
end
