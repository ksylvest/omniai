# frozen_string_literal: true

module OmniAI
  module Mistral
    class OCR
      # Dimensions returned by the OCR API.
      class Dimensions
        # !@attribute [rw] width
        #   @return [Integer]
        attr_accessor :width

        # !@attribute [rw] height
        #   @return [Integer]
        attr_accessor :height

        # !@attribute [rw] dpi
        #   @return [Integer]
        attr_accessor :dpi

        # @param width [Integer]
        # @param height [Integer]
        # @param dpi [Integer]
        def initialize(width:, height:, dpi:)
          @width = width
          @height = height
          @dpi = dpi
        end

        # @param data [Hash]
        #
        # @return [Dimensions]
        def self.parse(data:)
          new(width: data["width"], height: data["height"], dpi: data["dpi"])
        end
      end
    end
  end
end
