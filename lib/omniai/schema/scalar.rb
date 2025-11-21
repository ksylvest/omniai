# frozen_string_literal: true

module OmniAI
  module Schema
    # @example
    #   scalar = OmniAI::Schema::Scalar.deserialize({ type: "string" })
    #   scalar.serialize #=> { type: "string" }
    #   scalar.parse("Hello World") #=> "Hello World"
    #
    # @example
    #   scalar = OmniAI::Schema::Scalar.deserialize({ type: "integer" })
    #   scalar.serialize #=> { type: "integer" }
    #   scalar.parse("123") #=> 123
    #
    # @example
    #   scalar = OmniAI::Schema::Scalar.deserialize({ type: "number" })
    #   scalar.serialize #=> { type: "number" }
    #   scalar.parse("123.45") #=> 123.45
    #
    # @example
    #  scalar = OmniAI::Schema::Scalar.deserialize({ type: "boolean" })
    #  scalar.serialize #=> { type: "boolean" }
    #  scalar.parse(true) #=> true
    #  scalar.parse(false) #=> false
    class Scalar
      module Type
        BOOLEAN = "boolean"
        INTEGER = "integer"
        STRING = "string"
        NUMBER = "number"
      end

      # @!attribute [rw] type
      #   @return [String]
      attr_accessor :type

      # @!attribute [rw] description
      #   @return [String, nil]
      attr_accessor :description

      # @!attribute [rw] enum
      #   @return [Array<String>, nil]
      attr_accessor :enum

      # @example
      #   property = OmniAI::Schema::Scalar.deserialize({
      #     type: "string",
      #     description: "A predefined color.",
      #     enum: %w[red organge yellow green blue indigo violet],
      #   })
      #
      # @example
      #   property = OmniAI::Schema::Scalar.deserialize({
      #     type: "integer",
      #   })
      #
      # @example
      #   property = OmniAI::Schema::Scalar.deserialize({
      #     type: "number",
      #   })
      #
      # @example
      #   property = OmniAI::Schema::Scalar.deserialize({
      #     type: "boolean",
      #   })
      #
      # @param data [Hash]
      #
      # @return [OmniAI::Schema::Scalar]
      def self.deserialize(data)
        type = data["type"] || data[:type] || Type::STRING
        description = data["description"] || data[:description]
        enum = data["enum"] || data[:enum]

        new(type:, description:, enum:)
      end

      # @param type [String] required - the type of the property
      # @param description [String] optional - a description of the property
      # @param enum [Array] optional - the possible values of the property
      #
      # @return [OmniAI::Schema::Scalar]
      def initialize(type:, description: nil, enum: nil)
        super()
        @type = type
        @description = description
        @enum = enum
      end

      # @example
      #   property.serialize #=> { type: "string" }
      #
      # @return [Hash]
      def serialize(*)
        {
          type: @type,
          description: @description,
          enum: @enum,
        }.compact
      end

      # @example
      #   property.parse("123") #=> 123
      #
      # @param value [String, Integer, Float, Boolean, Object]
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
