# frozen_string_literal: true

module OmniAI
  # An abstract class that provides a consistent interface for processing embedding requests.
  #
  # Usage:
  #
  #   class OmniAI::OpenAI::Embed < OmniAI::Embed
  #     module Model
  #       SMALL = "text-embedding-3-small"
  #       LARGE = "text-embedding-3-large"
  #       ADA = "text-embedding-3-002"
  #     end
  #
  #     protected
  #
  #     # @return [Hash]
  #     def payload
  #       { ... }
  #     end
  #
  #     # @return [String]
  #     def path
  #       "..."
  #     end
  #   end
  #
  #   client.embed(input, model: "...")
  class Embed
    def self.process!(...)
      new(...).process!
    end

    # @param input [String] required
    # @param client [Client] the client
    # @param model [String] required
    #
    # @return [Response]
    def initialize(input, client:, model:)
      @input = input
      @client = client
      @model = model
    end

    # @raise [Error]
    # @return [Response]
    def process!
      response = request!
      raise HTTPError, response.flush unless response.status.ok?

      parse!(response:)
    end

  protected

    # Override  to provide a context (serializers / deserializes) for a provider.
    #
    # @return [Context, nil]
    def context
      nil
    end

    # @param response [HTTP::Response]
    # @return [Response]
    def parse!(response:)
      Response.new(data: response.parse, context:)
    end

    # @return [HTTP::Response]
    def request!
      @client
        .connection
        .accept(:json)
        .post(path, params:, json: payload)
    end

    # @return [Hash]
    def params
      {}
    end

    # @return [Hash]
    def payload
      raise NotImplementedError, "#{self.class.name}#payload undefined"
    end

    # @return [String]
    def path
      raise NotImplementedError, "#{self.class.name}#path undefined"
    end
  end
end
