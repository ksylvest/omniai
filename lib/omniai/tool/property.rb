# frozen_string_literal: true

module OmniAI
  class Tool
    # A property used for a tool parameter.
    #
    # @example
    #   OmniAI::Tool::Property.array(description: '...', items: ...)
    #   OmniAI::Tool::Property.object(description: '...', properties: { ... }, required: %i[...])
    #   OmniAI::Tool::Property.string(description: '...')
    #   OmniAI::Tool::Property.integer(description: '...')
    #   OmniAI::Tool::Property.number(description: '...')
    #   OmniAI::Tool::Property.boolean(description: '...')
    class Property
      module Type
        BOOLEAN = "boolean"
        INTEGER = "integer"
        STRING = "string"
        NUMBER = "number"
      end

      # @return [String]
      attr_reader :type

      # @return [String, nil]
      attr_reader :description

      # @return [Array<String>, nil]
      attr_reader :enum

      # @example
      #   property = OmniAI::Tool::Property.array(
      #     items: OmniAI::Tool::Property.string(description: 'The name of the person.'),
      #     description: 'A list of names.'
      #     min_items: 1,
      #     max_items: 5,
      #   )
      #
      # @param items [OmniAI::Tool::Property] required - the items in the array
      # @param min_items [Integer] optional - the minimum number of items
      # @param max_items [Integer] optional - the maximum number of items
      # @param description [String] optional - a description of the array
      #
      # @return [OmniAI::Tool::Array]
      def self.array(items:, min_items: nil, max_items: nil, description: nil)
        OmniAI::Tool::Array.new(items:, description:, min_items:, max_items:)
      end

      # @example
      #   property = OmniAI::Tool::Property.object(
      #     properties: {
      #       name: OmniAI::Tool::Property.string(description: 'The name of the person.'),
      #       age: OmniAI::Tool::Property.integer(description: 'The age of the person.'),
      #       employeed: OmniAI::Tool::Property.boolean(description: 'Is the person employeed?'),
      #     },
      #     description: 'A person.'
      #     required: %i[name]
      #   )
      #
      # @param properties [Hash<String, OmniAI::Tool::Property>] required - the properties of the object
      # @param required [Array<Symbol>] optional - the required properties
      # @param description [String] optional - a description of the object
      #
      # @return [OmniAI::Tool::Array]
      def self.object(properties: {}, required: [], description: nil)
        OmniAI::Tool::Object.new(properties:, required:, description:)
      end

      # @param description [String] optional - a description of the property
      # @param enum [Array<Boolean>] optional - the possible values of the property
      #
      # @return [OmniAI::Tool::Property]
      def self.boolean(description: nil, enum: nil)
        new(type: Type::BOOLEAN, description:, enum:)
      end

      # @param description [String] optional - a description of the property
      # @param enum [Array<Integer>] optinoal - the possible values of the property
      #
      # @return [OmniAI::Tool::Property]
      def self.integer(description: nil, enum: nil)
        new(type: Type::INTEGER, description:, enum:)
      end

      # @param description [String] optional - a description of the property
      # @param enum [Array<String>] optional - the possible values of the property
      #
      # @return [OmniAI::Tool::Property]
      def self.string(description: nil, enum: nil)
        new(type: Type::STRING, description:, enum:)
      end

      # @param description [String] optional - a description of the property
      # @param enum [Array<Number>] optional - the possible values of the property
      #
      # @return [OmniAI::Tool::Property]
      def self.number(description: nil, enum: nil)
        new(type: Type::NUMBER, description:, enum:)
      end

      # @param type [String] required - the type of the property
      # @param description [String] optional - a description of the property
      # @param enum [Array] optional - the possible values of the property
      #
      # @return [OmniAI::Tool::Property]
      def initialize(type:, description: nil, enum: nil)
        @type = type
        @description = description
        @enum = enum
      end

      # @example
      #   property.serialize #=> { type: 'string' }
      #
      # @return [Hash]
      def serialize
        {
          type: @type,
          description: @description,
          enum: @enum,
        }.compact
      end

      # @example
      #   property.parse('123') #=> 123
      #
      # @return [String, Integer, Float, Boolean, Object]
      def parse(value)
        case @type
        when Type::INTEGER then Integer(value)
        when Type::STRING then String(value)
        when Type::NUMBER then Float(value)
        else value
        end
      end
    end
  end
end
