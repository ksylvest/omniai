# frozen_string_literal: true

module OmniAI
  module Anthropic
    class Chat
      # Overrides function serialize / deserialize.
      module FunctionSerializer
        # @param function [OmniAI::Chat::Function]
        #
        # @return [Hash]
        def self.serialize(function, *)
          {
            name: function.name,
            input: function.arguments,
          }
        end

        # @param data [Hash]
        #
        # @return [OmniAI::Chat::Function]
        def self.deserialize(data, *)
          name = data["name"]
          arguments = data["input"]

          OmniAI::Chat::Function.new(name:, arguments:)
        end
      end
    end
  end
end
