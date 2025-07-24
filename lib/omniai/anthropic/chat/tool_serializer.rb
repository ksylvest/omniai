# frozen_string_literal: true

module OmniAI
  module Anthropic
    class Chat
      # Overrides tool serialize / deserialize.
      module ToolSerializer
        # @param tool [OmniAI::Tool]
        # @return [Hash]
        def self.serialize(tool, *)
          {
            name: tool.name,
            description: tool.description,
            input_schema: tool.parameters.is_a?(OmniAI::Schema::Object) ? tool.parameters.serialize : tool.parameters,
          }.compact
        end
      end
    end
  end
end
