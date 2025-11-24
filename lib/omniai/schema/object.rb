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
    class Object < Base
      TYPE = "object"

      # @!attribute [rw] properties
      #   @return [Hash]
      attr_accessor :properties

      # @!attribute [rw] required
      #   @return [Array<String>]
      attr_accessor :required

      # @param title [String] optional
      # @param description [String] optional
      # @param properties [Hash] optional
      # @param required [Array<String>] optional
      # @param nulable [Boolean] optional
      def initialize(title: nil, description: nil, properties: {}, required: [], nullable: nil)
        super(title:, description:, nullable:)
        @properties = properties
        @required = required
      end

      # @return [OmniAI::Schema::Object]
      def dup
        self.class.new(
          title: @title,
          description: @description,
          properties: @properties.dup,
          required: @required.dup,
          nullable: @nullable
        )
      end

      # @param data [Hash]
      #
      # @return [Hash]
      def parse(data)
        return if data.nil? && nullable?

        result = {}
        @properties.each do |name, property|
          value = data[String(name)]
          result[name.intern] = property.parse(value) unless value.nil?
        end
        result
      end

      # @param additional_properties [Boolean, nil] optional
      # @param require_all [Boolean, nil] optional
      #
      # @return [Hash]
      def serialize(additional_properties: false)
        {
          type: nullify(TYPE),
          title: @title,
          description: @description,
          properties: @properties.transform_values { |value| value.serialize(additional_properties:) },
          required: @required,
          additionalProperties: additional_properties,
        }.compact
      end

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
        nullable = Array(data["type"] || data[:type]).include?("null")
        title = data["title"] || data[:title]
        description = data["description"] || data[:description]
        properties = (data["properties"] || data[:properties]).transform_values { |i| OmniAI::Schema.deserialize(i) }
        required = data["required"] || data[:required] || []

        new(title:, description:, properties:, required:, nullable:)
      end
    end
  end
end
