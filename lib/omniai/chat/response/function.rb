# frozen_string_literal: true

module OmniAI
  class Chat
    module Response
      # A function returned by the API.
      class Function < Resource
        # @return [String]
        def inspect
          "#<#{self.class.name} name=#{name.inspect} arguments=#{arguments.inspect}>"
        end

        # @return [String]
        def name
          @data['name']
        end

        # @return [Hash, nil]
        def arguments
          JSON.parse(@data['arguments']) if @data['arguments']
        end
      end
    end
  end
end
