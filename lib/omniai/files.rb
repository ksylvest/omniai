# frozen_string_literal: true

module OmniAI
  # A manager for files.
  class Files
    # @param client [OmniAI::Client]
    def initialize(client:)
      @client = client
    end
  end
end
