# frozen_string_literal: true

module OmniAI
  class Tool
    # Usage:
    #
    # property = OmniAI::Tool::Property.new(type: 'string', description: 'The nth number to calculate.')
    class Property
      module Type
        BOOLEAN = 'boolean'
        INTEGER = 'integer'
        STRING = 'string'
        NUMBER = 'number'
      end

      # @return [String]
      attr_reader :type

      # @return [String, nil]
      attr_reader :description

      # @return [Array<String>, nil]
      attr_reader :enum

      # @param description [String]
      # @param enum [Array<String>]
      # @return [OmniAI::Tool::Property]
      def self.boolean(description: nil, enum: nil)
        new(type: Type::BOOLEAN, description:, enum:)
      end

      # @param description [String]
      # @param enum [Array<String>]
      # @return [OmniAI::Tool::Property]
      def self.integer(description: nil, enum: nil)
        new(type: Type::INTEGER, description:, enum:)
      end

      # @param description [String]
      # @param enum [Array<String>]
      # @return [OmniAI::Tool::Property]
      def self.string(description: nil, enum: nil)
        new(type: Type::STRING, description:, enum:)
      end

      # @param description [String]
      # @param enum [Array<String>]
      # @return [OmniAI::Tool::Property]
      def self.number(description: nil, enum: nil)
        new(type: Type::NUMBER, description:, enum:)
      end

      # @param description [String]
      # @param enum [Array<String>]
      # @return [OmniAI::Tool::Property]
      def initialize(type:, description: nil, enum: nil)
        @type = type
        @description = description
        @enum = enum
      end

      # @example
      #   property.prepare
      #   # {
      #   #   type: 'string',
      #   #   description: 'The unit (e.g. "fahrenheit" or "celsius").'
      #   #   enum: %w[fahrenheit celsius]
      #   # }
      #
      # @return [Hash]
      def prepare
        {
          type: @type,
          description: @description,
          enum: @enum,
        }.compact
      end

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
