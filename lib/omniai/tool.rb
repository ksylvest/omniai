# frozen_string_literal: true

module OmniAI
  # Usage:
  #
  #   fibonacci = proc do |n:|
  #     next(0) if n == 0
  #     next(1) if n == 1
  #     fibonacci.call(n: n - 1) + fibonacci.call(n: n - 2)
  #   end
  #
  #   tool = OmniAI::Tool.new(fibonacci,
  #     name: 'Fibonacci',
  #     description: 'Cacluate the nth Fibonacci',
  #     parameters: OmniAI::Tool::Parameters.new(
  #       properties: {
  #         n: OmniAI::Tool::Property.integer(description: 'The nth Fibonacci number to calculate')
  #       },
  #       required: %i[n],
  #      )
  #   )
  class Tool
    # @return [Proc]
    attr_accessor :function

    # @return [String]
    attr_accessor :name

    # @return [String, nil]
    attr_accessor :description

    # @return [Hash, nil]
    attr_accessor :parameters

    # @param function [Proc]
    # @param name [String]
    # @param description [String]
    # @param parameters [Hash]
    def initialize(function, name:, description: nil, parameters: nil)
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
