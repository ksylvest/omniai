# frozen_string_literal: true

module OmniAI
  class Chat
    module Response
      # A generic data to handle response.
      class Resource
        attr_accessor :data

        # @param data [Hash]
        def initialize(data:)
          @data = data
        end

        # @return [String]
        def inspect
          "#<#{self.class.name} data=#{@data.inspect}>"
        end
      end
    end
  end
end
