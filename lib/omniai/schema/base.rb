# frozen_string_literal: true

module OmniAI
  module Schema
    # @example
    #    object = OmniAI::Tool::Base.deserialize({ ... })
    #    object.serialize # => { ... }
    #    object.parse(...]
    class Base
      # @!attribute [rw] title
      #   @return [String, nil]
      attr_accessor :title

      # @!attribute [rw] description
      #   @return [String, nil]
      attr_accessor :description

      # @param title [String] optional
      # @param description [String] optional
      # @param nullable [Boolean] optional
      def initialize(title: nil, description: nil, nullable: nil)
        super()
        @title = title
        @description = description
        @nullable = nullable
      end

      # @param value [Object]
      # @return Object
      def parse(value)
        raise NotImplementedError, "#parse undefined"
      end

      # @param additional_properties [Boolean]
      #
      # @return [Hash]
      def serialize(additional_properties: false)
        raise NotImplementedError, "#serialize undefined"
      end

      # @param data [Hash]
      #
      # @return [OmniAI::Schema::Base]
      def self.deserialize(data)
        raise NotImplementedError, ".deserialize undefined"
      end

      # @return [Boolean]
      def nullable?
        !!@nullable
      end

      # @return [OmniAI::Schema::Base]
      def nullable
        dup.tap do |object|
          object.nullable = true
        end
      end

      def nonnullable
        dup.tap do |object|
          object.nullable = false
        end
      end

    protected

      def nullify(type)
        nullable? ? ["null", type] : type
      end
    end
  end
end
