# frozen_string_literal: true

module OmniAI
  # @example
  #   format = OmniAI::Schema.format(name: "Contact", schema: OmniAI::Schema.object(
  #     description: "A contact with a name, relationship, and addresses.",
  #     properties: {
  #       name: OmniAI::Schema.string,
  #       relationship: OmniAI::Schema.string(enum: %w[friend family]),
  #       addresses: OmniAI::Schema.array(
  #         items: OmniAI::Schema.object(
  #           title: "Address",
  #           description: "An address with street, city, state, and zip code.",
  #           properties: {
  #             street: OmniAI::Schema.string,
  #             city: OmniAI::Schema.string,
  #             state: OmniAI::Schema.string,
  #             zip: OmniAI::Schema.string,
  #           },
  #           required: %i[street city state zip]
  #         )
  #       ),
  #     },
  #     required: %i[name]
  #   ))
  module Schema
    # @example
    #   OmniAI::Schema.deserialize({
    #     type: 'object',
    #     title: 'Person',
    #     properties: { name: { type: 'string' } },
    #     required: %i[name],
    #   }) # => OmniAI::Schema::Object
    #
    # @example
    #   OmniAI::Schema.deserialize({
    #     type: 'array',
    #     items: { type: 'string' },
    #   }) # => OmniAI::Schema::Array
    #
    # @example
    #   OmniAI::Schema.deserialize({
    #     type: 'string',
    #     description: '...',
    #     enum: ['...', ],
    #   }) # => OmniAI::Schema::Scalar
    #
    # @param data [OmniAI::Schema::Object, OmniAI::Schema::Array, OmniAI::Schema::Scalar]
    def self.deserialize(data)
      type = Array(data["type"] || data[:type]).find { |type| !type.eql?("null") }

      case type
      when OmniAI::Schema::Array::TYPE then OmniAI::Schema::Array.deserialize(data)
      when OmniAI::Schema::Object::TYPE then OmniAI::Schema::Object.deserialize(data)
      else OmniAI::Schema::Scalar.deserialize(data)
      end
    end

    # @param kind [Symbol]
    #
    # @return [OmniAI::Schema::Object, OmniAI::Schema::Array, OmniAI::Schema::Scalar]
    def self.build(kind, **args)
      case kind
      when :array then array(**args)
      when :object then object(**args)
      when :boolean then boolean(**args)
      when :integer then integer(**args)
      when :number then number(**args)
      when :string then string(**args)
      end
    end

    # @example
    #   property = OmniAI::Schema.array(
    #     items: OmniAI::Schema.string(description: 'The name of the person.'),
    #     description: 'A list of names.'
    #     min_items: 1,
    #     max_items: 5,
    #   )
    #
    # @param items [OmniAI::Schema::Scalar] required - the items in the array
    # @param min_items [Integer] optional - the minimum number of items
    # @param max_items [Integer] optional - the maximum number of items
    # @param description [String] optional - a description of the array
    # @param nullable [Boolean] optional - if the array may be null
    #
    # @return [OmniAI::Schema::Array]
    def self.array(items:, min_items: nil, max_items: nil, description: nil, nullable: nil)
      OmniAI::Schema::Array.new(items:, description:, min_items:, max_items:, nullable:)
    end

    # @example
    #   property = OmniAI::Schema.object(
    #     properties: {
    #       name: OmniAI::Schema.string(description: 'The name of the person.'),
    #       age: OmniAI::Schema.integer(description: 'The age of the person.'),
    #       employed: OmniAI::Schema.boolean(description: 'Is the person employed?'),
    #     },
    #     description: 'A person.'
    #     required: %i[name]
    #   )
    #
    # @param title [String] optional - the title of the object
    # @param properties [Hash<String, OmniAI::Schema::Scalar>] required - the properties of the object
    # @param required [Array<Symbol>] optional - the required properties
    # @param description [String] optional - a description of the object
    # @param nullable [Boolean] optional - if the object may be null
    #
    # @return [OmniAI::Schema::Array]
    def self.object(title: nil, properties: {}, required: [], description: nil, nullable: nil)
      OmniAI::Schema::Object.new(title:, properties:, required:, description:, nullable:)
    end

    # @example
    #   OmniAI::Schema.boolean(description: "Is the person employed?") #=> OmniAI::Schema::Scalar
    #
    # @param title [String] optional - the title of the property
    # @param description [String] optional - a description of the property
    # @param enum [Array<Boolean>] optional - the possible values of the property
    # @param nullable [Boolean] optional - if the property may be null
    #
    # @return [OmniAI::Schema::Scalar]
    def self.boolean(title: nil, description: nil, enum: nil, nullable: nil)
      OmniAI::Schema::Scalar.new(type: OmniAI::Schema::Scalar::Type::BOOLEAN, title:, description:, enum:, nullable:)
    end

    # @example
    #   OmniAI::Schema.integer(description: "The age of the person") #=> OmniAI::Schema::Scalar
    #
    # @param title [String] optional - the title of the property
    # @param description [String] optional - a description of the property
    # @param enum [Array<Integer>] optional - the possible values of the property
    # @param nullable [Boolean] optional - if the property may be null
    #
    # @return [OmniAI::Schema::Scalar]
    def self.integer(title: nil, description: nil, enum: nil, nullable: nil)
      OmniAI::Schema::Scalar.new(type: OmniAI::Schema::Scalar::Type::INTEGER, title:, description:, enum:, nullable:)
    end

    # @example
    #   OmniAI::Schema.string(description: "The name of the person.") #=> OmniAI::Schema::Scalar
    #
    # @param title [String] optional - the title of the property
    # @param description [String] optional - a description of the property
    # @param enum [Array<String>] optional - the possible values of the property
    # @param nullable [Boolean] optional - if the property may be null
    #
    # @return [OmniAI::Schema::Scalar]
    def self.string(title: nil, description: nil, enum: nil, nullable: nil)
      OmniAI::Schema::Scalar.new(type: OmniAI::Schema::Scalar::Type::STRING, title:, description:, enum:, nullable:)
    end

    # @example
    #  OmniAI::Schema.number(description: "The current temperature.") #=> OmniAI::Schema::Scalar
    #
    # @param title [String] optional - the title of the property
    # @param description [String] optional - a description of the property
    # @param enum [Array<Number>] optional - the possible values of the property
    # @param nullable [Boolean] optional - if the property may be null
    #
    # @return [OmniAI::Schema::Scalar]
    def self.number(title: nil, description: nil, enum: nil, nullable: nil)
      OmniAI::Schema::Scalar.new(type: OmniAI::Schema::Scalar::Type::NUMBER, title:, description:, enum:, nullable:)
    end

    # @example
    #   OmniAI::Schema.format(name: "Contact", schema: OmniAI::Schema.object(...)) #=> OmniAI::Schema::Format
    #
    # @param name [String] required
    # @param schema [OmniAI::Schema::Object] required
    # @param nullable [Boolean] optional
    #
    # @return [OmniAI::Schema::Format]
    def self.format(name:, schema:)
      OmniAI::Schema::Format.new(name:, schema:)
    end
  end
end
