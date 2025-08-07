# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Thread
      # An OpenAI scope for establishing messages.
      class Runs
        # @param client [OmniAI::OpenAI::Client] required
        # @param thread [OmniAI::OpenAI::Thread] required
        def initialize(client:, thread:)
          @client = client
          @thread = thread
        end

        # @param limit [Integer] optional
        # @return [Array<OmniAI::Thread::Message>]
        def all(limit: nil)
          Run.all(thread_id: @thread.id, limit:, client: @client)
        end

        # @param id [String] required
        # @return [OmniAI::OpenAI::Thread::Message]
        def find(id:)
          Run.find(id:, thread_id: @thread.id, client: @client)
        end

        # @param id [String] required
        # @return [Hash]
        def cancel!(id:)
          Run.cancel!(id:, thread_id: @thread.id, client: @client)
        end

        # @param assistant_id [String] required
        # @param model [String, nil] optional
        # @param temperature [Float, nil] optional
        # @param instructions [String, nil] optional
        # @param tools [Array<Hash>, nil] optional
        # @param metadata [Hash, nil] optional
        # @return [OmniAI::OpenAI::Thread::Message]
        def build(assistant_id:, model: nil, temperature: nil, instructions: nil, tools: nil, metadata: {})
          Run.new(
            assistant_id:,
            thread_id: @thread.id,
            model:,
            temperature:,
            instructions:,
            tools:,
            metadata:,
            client: @client
          )
        end
      end
    end
  end
end
