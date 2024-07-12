# frozen_string_literal: true

module OmniAI
  class Chat
    module Response
      # A chunk or completion.
      class Payload < Resource
        # @return [String]
        def inspect
          "#<#{self.class.name} id=#{id.inspect} choices=#{choices.inspect}>"
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

        # @return [Array<OmniAI::Chat::Response::Choice>]
        def choices
          raise NotImplementedError, "#{self.class.name}#choices undefined"
        end

        # @param index [Integer]
        # @return [OmniAI::Chat::Response::DeltaChoice]
        def choice(index: 0)
          choices[index]
        end

        # @return [OmniAI::Chat::Response::Usage]
        def usage
          @usage ||= Usage.new(data: @data['usage']) if @data['usage']
        end

        # @return [Boolean]
        def tool_call_required?
          choices.any?(&:tool_call_required)
        end

        # @return [Array<OmniAI::Chat::Response:ToolCall>]
        def tool_call_list
          list = []
          choices.each do |choice|
            list += choice.tool_call_list
          end
          list
        end
      end
    end
  end
end
