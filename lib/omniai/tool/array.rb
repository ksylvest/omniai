# frozen_string_literal: true

module OmniAI
  class Tool
    # Represents a schema object.
    #
    # @example
    #    array = OmniAI::Tool::Array.new(
    #      description: 'A list of people.',
    #      items: OmniAI::Tool::Object.new(
    #        properties: {
    #          name: OmniAI::Tool::Property.string(description: 'The name of the person.'),
    #          age: OmniAI::Tool::Property.integer(description: 'The age of the person.'),
    #        },
    #        required: %i[name]
    #      ),
    #      min_items: 1,
    #      max_items: 5,
    #    })
    class Array
      TYPE = 'array'

      # @!attribute [rw] items
      #   @return [OmniAI::Tool::Object, OmniAI::Tool::Array, OmniAI::Tool::Property]
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

      # @param items [OmniAI::Tool::Object, OmniAI::Tool::Array, OmniAI::Tool::Property] required
      # @param max_items [Integer] optional
      # @param min_items [Integer] optional
      # @param description [String] optional
      def initialize(items:, max_items: nil, min_items: nil, description: nil)
        @items = items
        @description = description
        @max_items = max_items
        @min_items = min_items
      end

      # @example
      #   array.serialize # => { type: 'array', items: { type: 'string' } }
      #
      # @return [Hash]
      def serialize
        {
          type: TYPE,
          description: @description,
          items: @items.serialize,
          maxItems: @max_items,
          minItems: @min_items,
        }.compact
      end

      # @example
      #   array.parse(['1', '2', '3']) # => [1, 2, 3]
      # @param args [Array]
      #
      # @return [Array]
      def parse(args)
        args.map { |arg| @items.parse(arg) }
      end
    end
  end
end
