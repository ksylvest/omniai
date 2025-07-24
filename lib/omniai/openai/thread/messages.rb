# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Thread
      # An OpenAI scope for establishing messages.
      class Messages
        # @param client [OmniAI::OpenAI::Client] required
        # @param thread [OmniAI::OpenAI::Thread] required
        def initialize(client:, thread:)
          @client = client
          @thread = thread
        end

        # @param limit [Integer] optional
        # @return [Array<OmniAI::Thread::Message>]
        def all(limit: nil)
          Message.all(thread_id: @thread.id, limit:, client: @client)
        end

        # @param id [String] required
        # @return [OmniAI::OpenAI::Thread::Message]
        def find(id:)
          Message.find(id:, thread_id: @thread.id, client: @client)
        end

        # @param id [String] required
        # @return [Hash]
        def destroy!(id:)
          Message.destroy!(id:, thread_id: @thread.id, client: @client)
        end

        # @param role [String, nil] optional
        # @param content [String, Array, nil] optional
        # @param attachments [Array, nil] optional
        # @param metadata [Hash, nil] optional
        # @return [OmniAI::OpenAI::Thread::Message]
        def build(role: nil, content: nil, attachments: [], metadata: {})
          Message.new(role:, content:, attachments:, metadata:, thread_id: @thread.id, client: @client)
        end
      end
    end
  end
end
