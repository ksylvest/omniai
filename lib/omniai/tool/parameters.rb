# frozen_string_literal: true

module OmniAI
  class Tool
    # Usage:
    #
    # parameters = OmniAI::Tool::Parameters.new(properties: {
    #   n: OmniAI::Tool::Parameters.integer(description: 'The nth number to calculate.')
    #   required: %i[n]
    # })
    class Parameters
      module Type
        OBJECT = 'object'
      end

      # @param type [String]
      # @param properties [Hash]
      # @param required [Array<String>]
      # @return [OmniAI::Tool::Parameters]
      def initialize(type: Type::OBJECT, properties: {}, required: [])
        @type = type
        @properties = properties
        @required = required
      end

      # @return [Hash]
      def prepare
        {
          type: @type,
          properties: @properties.transform_values(&:prepare),
          required: @required,
        }.compact
      end

      # @param args [Hash]
      # @return [Hash]
      def parse(args)
        result = {}
        @properties.each do |name, property|
          value = args[String(name)]
          result[name.intern] = property.parse(value) if value
        end
        result
      end
    end
  end
end
