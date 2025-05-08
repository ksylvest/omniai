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
      case data["type"] || data[:type]
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
    #
    # @return [OmniAI::Schema::Array]
    def self.array(items:, min_items: nil, max_items: nil, description: nil)
      OmniAI::Schema::Array.new(items:, description:, min_items:, max_items:)
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
    #
    # @return [OmniAI::Schema::Array]
    def self.object(title: nil, properties: {}, required: [], description: nil)
      OmniAI::Schema::Object.new(title:, properties:, required:, description:)
    end

    # @example
    #   OmniAI::Schema.boolean(description: "Is the person employed?") #=> OmniAI::Schema::Scalar
    #
    # @param description [String] optional - a description of the property
    # @param enum [Array<Boolean>] optional - the possible values of the property
    #
    # @return [OmniAI::Schema::Scalar]
    def self.boolean(description: nil, enum: nil)
      OmniAI::Schema::Scalar.new(type: OmniAI::Schema::Scalar::Type::BOOLEAN, description:, enum:)
    end

    # @example
    #   OmniAI::Schema.integer(description: "The age of the person") #=> OmniAI::Schema::Scalar
    #
    # @param description [String] optional - a description of the property
    # @param enum [Array<Integer>] optinoal - the possible values of the property
    #
    # @return [OmniAI::Schema::Scalar]
    def self.integer(description: nil, enum: nil)
      OmniAI::Schema::Scalar.new(type: OmniAI::Schema::Scalar::Type::INTEGER, description:, enum:)
    end

    # @example
    #   OmniAI::Schema.string(description: "The name of the person.") #=> OmniAI::Schema::Scalar
    #
    # @param description [String] optional - a description of the property
    # @param enum [Array<String>] optional - the possible values of the property
    #
    # @return [OmniAI::Schema::Scalar]
    def self.string(description: nil, enum: nil)
      OmniAI::Schema::Scalar.new(type: OmniAI::Schema::Scalar::Type::STRING, description:, enum:)
    end

    # @example
    #  OmniAI::Schema.number(description: "The current temperature.") #=> OmniAI::Schema::Scalar
    #
    # @param description [String] optional - a description of the property
    # @param enum [Array<Number>] optional - the possible values of the property
    #
    # @return [OmniAI::Schema::Scalar]
    def self.number(description: nil, enum: nil)
      OmniAI::Schema::Scalar.new(type: OmniAI::Schema::Scalar::Type::NUMBER, description:, enum:)
    end

    # @example
    #   OmniAI::Schema.format(name: "Contact", schema: OmniAI::Schema.object(...)) #=> OmniAI::Schema::Format
    #
    # @param name [String] required
    # @param schema [OmniAI::Schema::Object] required
    #
    # @return [OmniAI::Schema::Format]
    def self.format(name:, schema:)
      OmniAI::Schema::Format.new(name:, schema:)
    end
  end
end
