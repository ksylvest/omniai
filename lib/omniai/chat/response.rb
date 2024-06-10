# frozen_string_literal: true

module OmniAI
  class Chat
    # An abstract class that provides a consistent interface for processing chat responses.
    #
    # Usage:
    #
    #   class OmniAI::OpenAI::Chat::Response < OmniAI::Chat::Response
    #     def choices
    #       # TODO: implement
    #     end
    #   end
    class Response
      attr_accessor :data

      # @param data [Hash]
      def initialize(data:)
        @data = data
      end

      # @param [index] [Integer]
      # @return [OmniAI::Chat::Choice]
      def choice(index: 0)
        choices[index]
      end

      # @return [Array<OmniAI::Chat::Choice>]
      def choices
        raise NotImplementedError, "#{self.class.name}#choices undefined"
      end
    end
  end
end
