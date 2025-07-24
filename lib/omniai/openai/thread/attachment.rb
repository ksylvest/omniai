# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Thread
      # An OpenAI attachment.
      class Attachment
        # @!attribute [rw] data
        #   @return [Hash, nil]
        attr_accessor :data

        # @param data [Array]
        # @param client [OmniAI::OpenAI::Client]
        #
        # @return [Array<OmniAI::OpenAI::Thread::Content>, String, nil]
        def self.for(data:, client: Client.new)
          return data unless data.is_a?(Enumerable)

          data.map { |attachment| new(data: attachment, client:) }
        end

        # @param data [Hash]
        # @param client [OmniAI::OpenAI::Client]
        def initialize(data:, client: Client.new)
          @data = data
          @client = client
        end

        # @return [String] e.g. "text"
        def file_id
          @file_id ||= @data["file_id"]
        end

        # @return [Array<Hash>]
        def tools
          @tools ||= @data["tools"]
        end

        # @return [OmniAI::OpenAI::File]
        def file!
          @file ||= @client.files.find(id: file_id)
        end
      end
    end
  end
end
