# frozen_string_literal: true

module OmniAI
  class Tool
    # Represents a schema object.
    #
    # @example
    #    object = OmniAI::Tool::Object.new(
    #      properties: {
    #        name: OmniAI::Tool::Property.string(description: 'The name of the person.'),
    #        age: OmniAI::Tool::Property.integer(description: 'The age of the person.'),
    #      },
    #      required: %i[name]
    #    })
    class Object
      TYPE = "object"

      # @!attribute [rw] properties
      #   @return [Hash]
      attr_accessor :properties

      # @!attribute [rw] required
      #   @return [Array<String>]
      attr_accessor :required

      # @!attribute [rw] description
      #   @return [String, nil]
      attr_accessor :description

      # @param properties [Hash]
      # @param required [Array<String>]
      # @return [OmniAI::Tool::Parameters]
      def initialize(properties: {}, required: [], description: nil)
        @properties = properties
        @required = required
        @description = description
      end

      # @return [Hash]
      def serialize
        {
          type: TYPE,
          description: @description,
          properties: @properties.transform_values(&:serialize),
          required: @required,
        }.compact
      end

      # @param args [Hash]
      #
      # @return [Hash]
      def parse(args)
        result = {}
        @properties.each do |name, property|
          value = args[String(name)]
          result[name.intern] = property.parse(value) unless value.nil?
        end
        result
      end
    end
  end
end
