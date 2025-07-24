# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI scope for establishing files.
    class Files
      # @param client [OmniAI::OpenAI::Client] required
      def initialize(client:)
        @client = client
      end

      # @raise [OmniAI::Error]
      #
      # @param id [String] required
      #
      # @return [OmniAI::OpenAI::File]
      def find(id:)
        File.find(id:, client: @client)
      end

      # @raise [OmniAI::Error]
      #
      # @return [Array<OmniAI::OpenAI::File>]
      def all
        File.all(client: @client)
      end

      # @raise [OmniAI::Error]
      #
      # @param id [String] required
      def destroy!(id:)
        File.destroy!(id:, client: @client)
      end

      # @param io [IO] optional
      # @param purpose [String] optional
      #
      # @return [OmniAI::OpenAI::File]
      def build(io: nil, purpose: File::Purpose::ASSISTANTS)
        File.new(io:, purpose:, client: @client)
      end
    end
  end
end
