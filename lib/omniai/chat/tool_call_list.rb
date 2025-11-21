# frozen_string_literal: true

module OmniAI
  class Chat
    # An `OmniAI::Chat::ToolCallList` is a collection designed to handle the merging of multiple tool call arrays. LLMs
    # provide a subset of tool call items when chunking, so merging requires the use of the tool call index to combine.
    class ToolCallList
      include Enumerable

      # @param entries [Array<ToolCall>]
      def initialize(entries: [])
        @entries = entries
      end

      # Usage:
      #
      #   ToolCallList.deserialize([]) # => #<ToolCallList ...>
      #
      # @param data [Array]
      # @param context [Context] optional
      #
      # @return [ToolCallList]
      def self.deserialize(data, context: nil)
        return unless data

        new(entries: data.map { |subdata| ToolCall.deserialize(subdata, context:) })
      end

      # Usage:
      #
      #   tool_call_list.serialize # => [...]
      #
      # @param context [Context] optional
      #
      # @return [Array<Hash>]
      def serialize(context: nil)
        @entries.compact.map { |tool_call| tool_call.serialize(context:) }
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} entries=#{@entries.inspect}>"
      end

      # @yield toolcall
      # @yieldparam toolcall [ToolCall]
      def each(&)
        @entries.each(&)
      end

      # @return [ToolCall]
      def [](index)
        @entries[index]
      end

      # @param [other] [ToolCallList]
      def +(other)
        self.class.new(entries: entries + other.entries)
      end
    end
  end
end
