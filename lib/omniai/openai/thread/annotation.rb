# frozen_string_literal: true

module OmniAI
  module OpenAI
    class Thread
      # An OpenAI content w/ annotations.
      class Annotation
        # @!attribute [rw] data
        #   @return [Hash, nil]
        attr_accessor :data

        # @param data [Hash] required
        # @param client [OmniAI::OpenAI::Client] optional
        def initialize(data:, client: Client.new)
          @data = data
          @client = client
        end

        # @return [String] "file_citation" or "file_path"
        def type
          @data["type"]
        end

        # @return [String]
        def text
          @data["text"]
        end

        # @return [Integer]
        def start_index
          @data["start_index"]
        end

        # @return [Integer]
        def end_index
          @data["end_index"]
        end

        # @return [Range<Integer>]
        def range
          start_index..end_index
        end

        # @return [String]
        def file_id
          @file_id ||= (@data["file_citation"] || @data["file_path"])["file_id"]
        end

        # Present if type is "file_citation" or "file_path".
        #
        # @return [OmniAI::OpenAI::File, nil]
        def file!
          @file ||= @client.files.find(id: file_id)
        end
      end
    end
  end
end
