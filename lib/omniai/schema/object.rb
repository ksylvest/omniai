# frozen_string_literal: true

module OmniAI
  module Schema
    # @example
    #    schema = OmniAI::Schema::Object.deserialize({
    #      type: "object",
    #      properties: {
    #        name: { type: "string" }
    #      },
    #      required: ["name"],
    #    })
    #    schema.serialize #=> { type: "object", properties: { ... }, required: %i[name] }
    #    schema.parse({ "name" => "John Doe" }) #=> { name: "John Doe" }
    class Object
      TYPE = "object"

      # @!attribute [rw] properties
      #   @return [Hash]
      attr_accessor :properties

      # @!attribute [rw] required
      #   @return [Array<String>]
      attr_accessor :required

      # @!attribute [rw] title
      #   @return [String, nil]
      attr_accessor :title

      # @!attribute [rw] description
      #   @return [String, nil]
      attr_accessor :description

      # @example
      #    OmniAI::Schema::Object.deserialize({
      #      type: "object",
      #      properties: {
      #        name: { type: "string" }
      #      },
      #      required: ["name"],
      #    }) # => OmniAI::Schema::Object
      #
      # @param data [Hash]
      #
      # @return [OmniAI::Schema::Object]
      def self.deserialize(data)
        title = data["title"] || data[:title]
        description = data["description"] || data[:description]
        properties = (data["properties"] || data[:properties]).transform_values { |i| OmniAI::Schema.deserialize(i) }
        required = data["required"] || data[:required] || []

        new(title:, description:, properties:, required:)
      end

      # @param title [String] optional
      # @param description [String] optional
      # @param properties [Hash] optional
      # @param required [Array<String>] optional
      def initialize(title: nil, description: nil, properties: {}, required: [])
        super()
        @title = title
        @description = description
        @properties = properties
        @required = required
      end

      # @return [Hash]
      def serialize
        {
          type: TYPE,
          title: @title,
          description: @description,
          properties: @properties.transform_values(&:serialize),
          required: @required,
        }.compact
      end

      # @param name [Symbol]
      def property(name, ...)
        @properties[name] = OmniAI::Schema::Scalar.build(...)
      end

      # @param data [Hash]
      #
      # @return [Hash]
      def parse(data)
        result = {}
        @properties.each do |name, property|
          value = data[String(name)]
          result[name.intern] = property.parse(value) unless value.nil?
        end
        result
      end
    end
  end
end
