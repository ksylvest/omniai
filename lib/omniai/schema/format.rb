# frozen_string_literal: true

module OmniAI
  module Schema
    # @example
    #   format = OmniAI::Schema::Format.deserialize({
    #     name: "example",
    #     schema: {
    #       type: "object",
    #       properties: {
    #         name: { type: "string" },
    #       },
    #       required: ["name"],
    #     }
    #   })
    #   format.serialize # => { name: "example", schema: { ... } }
    class Format
      # @!attribute [rw] name
      #   @return [String]
      attr_accessor :name

      # @!attribute [rw] schema
      #   @return [OmniAI::Schema::Object]
      attr_accessor :schema

      # @example
      #   array = OmniAI::Schema::Format.deserialize({
      #     name: "Contact",
      #     schema: { ... },
      #   }) # => OmniAI::Schema::Format
      #
      # @param data [Hash]
      #
      # @return [OmniAI::Schema::Format]
      def self.deserialize(data)
        name = data["name"] || data[:name]
        schema = OmniAI::Schema.deserialize(data["schema"] || data[:schema])

        new(name:, schema:)
      end

      # @param name [String]
      # @param schema [OmniAI::Schema::Object]
      def initialize(name:, schema:)
        @name = name
        @schema = schema
      end

      # @example
      #   format.serialize # => { name: "...", schema: { ... } }
      #
      # @return [Hash]
      def serialize
        {
          name:,
          schema: schema.serialize,
        }
      end

      # @example
      #   format.parse("{ "name": "Ringo Starr" }"") # => { name: "Ringo Starr" }
      #
      # @param text [String]
      #
      # @raise OmniAI::ParseError
      #
      # @return [Hash]
      def parse(text)
        schema.parse(JSON.parse(text))
      rescue JSON::ParserError => e
        raise OmniAI::ParseError, "Unable to parse JSON text=#{text.inspect} message=#{e.message.inspect}."
      end

      # A helper used for LLMs that do not support passing in a schema using a dedicated argument.
      #
      # @example
      #   format.prompt #=> "Your response must match the following schema: ..."
      #
      # @return [String]
      def prompt
        <<~TEXT
          Your must respond with ONLY valid JSON matching this exact schema:

          #{JSON.generate(schema.serialize)}

          Do not include any preamble, explanation, heredocs, etc. Return only the JSON.
        TEXT
      end
    end
  end
end
