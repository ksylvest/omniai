# frozen_string_literal: true

module OmniAI
  module Mistral
    class OCR
      # An image returned by the OCR API.
      class Image
        # !@attribute [rw] id
        #   @return [Integer]
        attr_accessor :id

        # !@attribute [rw] top_left_x
        #   @return [Integer]
        attr_accessor :top_left_x

        # !@attribute [rw] top_left_y
        #   @return [Integer]
        attr_accessor :top_left_y

        # !@attribute [rw] bottom_right_x
        #   @return [Integer]
        attr_accessor :bottom_right_x

        # !@attribute [rw] bottom_right_y
        #   @return [Integer]
        attr_accessor :bottom_right_y

        # !@attribute [rw] image_base64
        #   @return [String]
        attr_accessor :image_base64

        # @param id [Integer]
        # @param top_left_x [Integer]
        # @param top_left_y [Integer]
        # @param bottom_right_x [Integer]
        # @param bottom_right_y [Integer]
        # @param image_base64 [String]
        def initialize(id:, top_left_x:, top_left_y:, bottom_right_x:, bottom_right_y:, image_base64:)
          @id = id
          @top_left_x = top_left_x
          @top_left_y = top_left_y
          @bottom_right_x = bottom_right_x
          @bottom_right_y = bottom_right_y
          @image_base64 = image_base64
        end

        # @param data [Hash]
        #
        # @return [Image]
        def self.parse(data:)
          new(
            id: data["id"],
            top_left_x: data["top_left_x"],
            top_left_y: data["top_left_y"],
            bottom_right_x: data["bottom_right_x"],
            bottom_right_y: data["bottom_right_y"],
            image_base64: data["image_base64"]
          )
        end
      end
    end
  end
end
