# frozen_string_literal: true

module OmniAI
  module Mistral
    class OCR
      # The response from the OCR API.
      class Response
        # !@attribute [rw] model
        #   @return [Array<Model>]
        attr_accessor :model

        # !@attribute [rw] pages
        #   @return [Array<Page>]
        attr_accessor :pages

        # @param model [String]
        # @param pages [Array<Page>]
        def initialize(model:, pages:)
          @model = model
          @pages = pages
        end

        # @param data [Hash]
        #
        # @return [Response]
        def self.parse(data:)
          new(model: data["model"], pages: data["pages"].map { |page| Page.parse(data: page) })
        end
      end
    end
  end
end
