# frozen_string_literal: true

module OmniAI
  # Usage:
  #
  #   class Weather < OmniAI::Tool
  #     description 'Find the weather for a location'
  #
  #     parameter :location, :string, description: 'The location to find the weather for (e.g. "Toronto, Canada").'
  #     parameter :unit, :string, description: 'The unit of measurement (e.g. "Celsius" or "Fahrenheit").'
  #     required %i[location]
  #
  #     def execute!(location:)
  #       # ...
  #     end
  #   end
  class Tool
    class << self
      # @param description [String]
      #
      # @return [String]
      def description(description = nil)
        return @description if description.nil?

        @description = description
      end

      # @return [OmniAI::Tool::Parameters]
      def parameters
        @parameters ||= Parameters.new
      end

      # @param name [Symbol]
      # @param kind [Symbol]
      def parameter(name, kind, **)
        parameters.properties[name] = Property.build(kind, **)
      end

      # @param names [Array<Symbol>]
      def required(names)
        parameters.required = names
      end

      # Converts a class name to a tool:
      #  - e.g. "IBM::Watson::SearchTool" => "ibm_watson_search"
      #
      # @return [String]
      def namify
        name
          .gsub("::", "_")
          .gsub(/(?<prefix>[A-Z+])(?<suffix>[A-Z][a-z])/, '\k<prefix>_\k<suffix>')
          .gsub(/(?<prefix>[a-z])(?<suffix>[A-Z])/, '\k<prefix>_\k<suffix>')
          .gsub(/_tool$/i, "")
          .downcase
      end
    end

    # @!attribute [rw] function
    #   @return [Proc]
    attr_accessor :function

    # @!attribute [rw] name
    #   @return [String]
    attr_accessor :name

    # @!attribute [rw] description
    #   @return [String, nil]
    attr_accessor :description

    # @!attribute [rw] parameters
    #   @return [Hash, nil]
    attr_accessor :parameters

    # @param function [Proc]
    # @param name [String]
    # @param description [String]
    # @param parameters [OmniAI::Tool::Parameters]
    def initialize(
      function = method(:execute),
      name: self.class.namify,
      description: self.class.description,
      parameters: self.class.parameters
    )
      @function = function
      @name = name
      @description = description
      @parameters = parameters
    end

    # @example
    #   tool.serialize
    #   # {
    #   #   type: 'function',
    #   #   function: {
    #   #     name: 'Fibonacci',
    #   #     description: 'Calculate the nth Fibonacci number',
    #   #     parameters: {
    #   #       type: 'object',
    #   #       properties: {
    #   #         n: {
    #   #           description: 'The nth Fibonacci number to calculate')
    #   #           type: 'integer'
    #   #         }
    #   #       },
    #   #       required: ['n']
    #   #     }
    #   #   }
    #   # }
    #
    # @param context [Context] optional
    # @return [Hash]
    def serialize(context: nil)
      serialize = context&.serializer(:tool)
      return serialize.call(self, context:) if serialize

      {
        type: "function",
        function: {
          name: @name,
          description: @description,
          parameters: @parameters.is_a?(Tool::Parameters) ? @parameters.serialize : @parameters,
        }.compact,
      }
    end

    def execute(...)
      raise NotImplementedError, "#{self.class}#execute undefined"
    end

    # @example
    #   tool.call({ "n" => 6 })
    #   #=> 8
    #
    # @param args [Hash]
    # @return [String]
    def call(args = {})
      @function.call(**(@parameters.is_a?(Tool::Parameters) ? @parameters.parse(args) : args))
    end
  end
end
