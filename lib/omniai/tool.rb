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
    #   tool.prepare
    #   # {
    #   #   type: 'function',
    #   #   function: {
    #   #     name: 'Fibonacci',
    #   #     description: 'Calculate the nth Fibonacci number',
    #   #     parameters: {
    #   #       type: 'object',
    #   #       properties: {
    #   #         n: OmniAI::Tool::Property.integer(description: 'The nth Fibonacci number to calculate')
    #   #       },
    #   #       required: ['n']
    #   #     }
    #   #   }
    #   # }
    #
    # @return [Hash]
    def prepare
      {
        type: 'function',
        function: {
          name: @name,
          description: @description,
          parameters: @parameters&.prepare,
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
      @function.call(**(@parameters ? @parameters.parse(args) : args))
    end
  end
end
