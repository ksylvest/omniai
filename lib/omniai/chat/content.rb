# frozen_string_literal: true

module OmniAI
  class Chat
    # A placeholder for parts of a message. Any subclass must implement the serializable interface.
    class Content
      # @return [String]
      def self.summarize(content)
        return content.map { |entry| summarize(entry) }.join("\n\n") if content.is_a?(Array)
        return content if content.is_a?(String)

        content.summarize
      end

      # @param context [Context] optional
      # @param direction [String] optional either "input" or "output"
      #
      # @return [String]
      def serialize(context: nil, direction: nil)
        raise NotImplementedError, "#{self.class}#serialize undefined"
      end

      # @param data [Hash, Array, String]
      # @param context [Context] optional
      #
      # @return [Content]
      def self.deserialize(data, context: nil)
        return data if data.nil?
        return data.map { |entry| deserialize(entry, context:) } if data.is_a?(Array)

        deserialize = context&.deserializer(:content)
        return deserialize.call(data, context:) if deserialize

        return data if data.is_a?(String)

        raise ArgumentError, "untyped data=#{data.inspect}" unless data.key?("type")

        case data["type"]
        when "text" then Text.deserialize(data, context:)
        when "thinking" then Thinking.deserialize(data, context:)
        when /(.*)_url/ then URL.deserialize(data, context:)
        else raise ArgumentError, "unknown type=#{data['type'].inspect}"
        end
      end
    end
  end
end
