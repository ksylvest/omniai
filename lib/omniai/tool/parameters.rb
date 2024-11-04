# frozen_string_literal: true

module OmniAI
  class Tool
    # Parameters are used to define the arguments for a tool.
    #
    # @example
    #    parameters = OmniAI::Tool::Parameters.new(properties: {
    #      people: OmniAI::Tool::Parameters.array(
    #        items: OmniAI::Tool::Parameters.object(
    #          properties: {
    #            name: OmniAI::Tool::Parameters.string(description: 'The name of the person.'),
    #            age: OmniAI::Tool::Parameters.integer(description: 'The age of the person.'),
    #            employeed: OmniAI::Tool::Parameters.boolean(description: 'Is the person employeed?'),
    #          }
    #      n: OmniAI::Tool::Parameters.integer(description: 'The nth number to calculate.')
    #      required: %i[n]
    #    })
    #    tool = OmniAI::Tool.new(fibonacci, parameters: parameters)
    class Parameters < Object
    end
  end
end
