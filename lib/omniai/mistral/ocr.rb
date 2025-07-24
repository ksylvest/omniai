# frozen_string_literal: true

module OmniAI
  module Mistral
    # An implementation of the OCR API.
    class OCR
      VERSION = "v1"

      module Kind
        DOCUMENT = :document
        IMAGE = :image
      end

      module Model
        OCR_LATEST = "mistral-ocr-latest"
      end

      DEFAULT_KIND = Kind::DOCUMENT
      DEFAULT_MODEL = Model::OCR_LATEST

      # @raise [Error]
      #
      # @param client [OmniAI::Mistral::Client]
      # @param document [String] a URL
      # @param kind [Symbol] optional
      # @param model [String] optional
      # @param options [Hash] optional (e.g. `{ image_limit: 4 }`)
      #
      # @return [Response]
      def self.process!(document, client:, kind: DEFAULT_KIND, model: DEFAULT_MODEL, options: {})
        new(document, client:, kind:, model:, options:).process!
      end

      # @param client [OmniAI::Mistral::Client]
      # @param document [String] a URL
      # @param kind [Symbol] optional
      # @param model [String] optional
      # @param options [Hash] optional (e.g. `{ image_limit: 4 }`)
      def initialize(document, client:, kind: DEFAULT_KIND, model: DEFAULT_MODEL, options: {})
        @document = document
        @client = client
        @options = options
        @kind = kind
        @model = model
      end

      # @raise [Error]
      #
      # @return [Response]
      def process!
        response = @client.connection.accept(:json).post("/#{VERSION}/ocr", json: @options.merge({
          model: @model,
          document: document!,
        }).compact)

        raise HTTPError, response.flush unless response.status.ok?

        Response.parse(data: response.parse)
      end

      # @return [Hash]
      def document!
        case @kind
        when Kind::DOCUMENT then { document_url: @document, type: "document_url" }
        when Kind::IMAGE then { image_url: @document, type: "image_url" }
        end
      end
    end
  end
end
