# frozen_string_literal: true

module OmniAI
  module Mistral
    class OCR
      # A page returned by the OCR API.
      class Page
        # !@attribute [rw] index
        #   @return [Integer]
        attr_accessor :index

        # !@attribute [rw] markdown
        #   @return [String]
        attr_accessor :markdown

        # !@attribute [rw] images
        #   @return [Array<Image>]
        attr_accessor :images

        # !@attribute [rw] dimensions
        #   @return [Dimensions]
        attr_accessor :dimensions

        # @param index [Integer]
        # @param markdown [String]
        # @param images [Array<Image>]
        # @param dimensions [Dimensions]
        def initialize(index:, markdown:, images:, dimensions:)
          @index = index
          @markdown = markdown
          @images = images
          @dimensions = dimensions
        end

        # @param data [Hash]
        #
        # @return [Page]
        def self.parse(data:)
          new(
            index: data["index"],
            markdown: data["markdown"],
            images: data["images"].map { |image_data| Image.parse(data: image_data) },
            dimensions: Dimensions.parse(data: data["dimensions"])
          )
        end
      end
    end
  end
end
