# frozen_string_literal: true

module OmniAI
  class Chat
    # A completion returned by the API.
    class Completion < OmniAI::Chat::Response::Resource
      # @return [String]
      def inspect
        "#<#{self.class.name} id=#{id.inspect} choices=#{choices.inspect}"
      end

      # @return [String]
      def id
        @data['id']
      end

      # @return [Time]
      def created
        Time.at(@data['created']) if @data['created']
      end

      # @return [Time]
      def updated
        Time.at(@data['updated']) if @data['updated']
      end

      # @return [String]
      def model
        @data['model']
      end

      # @return [OmniAI::Chat::Usage]
      def usage
        @usage ||= Usage.new(data: @data['usage']) if @data['usage']
      end

      # @return [Array<OmniAI::Chat::MessageChoice>]
      def choices
        @choices ||= @data['choices'].map { |data| MessageChoice.new(data:) }
      end

      # @param index [Integer] optional - default is 0
      # @return [OmniAI::Chat::MessageChoice]
      def choice(index: 0)
        choices[index]
      end

      # @return [Boolean]
      def tool_call_required?
        choices.any? { |choice| choice.message.tool_call_list.any? }
      end

      # @return [Array<OmniAI::Chat::ToolCall>]
      def tool_call_list
        list = []
        choices.each do |choice|
          list += choice.message.tool_call_list
        end
        list
      end
    end
  end
end
