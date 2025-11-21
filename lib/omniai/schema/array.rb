# frozen_string_literal: true

module OmniAI
  module Schema
    # @example
    #    array = OmniAI::Tool::Array.deserialize({
    #      description: "A list of people.",
    #      items: {
    #        properties: {
    #          name: { type: "string" },
    #        },
    #        required: ["name"],
    #      },
    #      min_items: 1,
    #      max_items: 5,
    #    })
    #    array.serialize # => { type: "array", items: { ... }, minItems: 1, maxItems: 5 }
    #    array.parse([{ "name" => "Ringo Starr" }]) # => [{ name: "Ringo Star" }]
    class Array
      TYPE = "array"

      # @!attribute [rw] items
      #   @return [OmniAI::Schema::Object, OmniAI::Schema::Array, OmniAI::Schema::Scalar]
      attr_accessor :items

      # @!attribute [rw] max_items
      #   @return [Integer, nil]
      attr_accessor :max_items

      # @!attribute [rw] min_items
      #   @return [Integer, nil]
      attr_accessor :min_items

      # @!attribute [rw] description
      #   @return [String, nil]
      attr_accessor :description

      # @example
      #   array = OmniAI::Schema::Array.deserialize({
      #     type: "array",
      #     items: { type: "string" },
      #     minItems: 1,
      #     maxItems: 5,
      #     description: "A list of strings."
      #   }) # => OmniAI::Schema::Array
      #
      # @param data [Hash]
      #
      # @return [OmniAI::Schema::Array]
      def self.deserialize(data)
        new(
          items: OmniAI::Schema.deserialize(data["items"] || data[:items]),
          max_items: data[:maxItems] || data["maxItems"],
          min_items: data[:minItems] || data["minItems"],
          description: data[:description] || data["description"]
        )
      end

      # @param items [OmniAI::Schema::Object, OmniAI::Schema::Array, OmniAI::Schema::Scalar] required
      # @param min_items [Integer] optional
      # @param max_items [Integer] optional
      # @param description [String] optional
      def initialize(items:, min_items: nil, max_items: nil, description: nil)
        super()
        @items = items
        @min_items = min_items
        @max_items = max_items
        @description = description
      end

      # @example
      #   array.serialize # => { type: "array", items: { type: "string" } }
      #
      # @param options [Hash] optional
      #
      # @return [Hash]
      def serialize(additional_properties: false)
        {
          type: TYPE,
          description: @description,
          items: @items.serialize(additional_properties:),
          maxItems: @max_items,
          minItems: @min_items,
        }.compact
      end

      # @example
      #   array.parse(["1", "2", "3"]) # => [1, 2, 3]
      #
      # @param data [Array]
      #
      # @return [Array]
      def parse(data)
        data.map { |arg| @items.parse(arg) }
      end
    end
  end
end
