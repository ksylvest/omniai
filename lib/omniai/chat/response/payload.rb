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

        # @return [Array<Choice>]
        def choices
          raise NotImplementedError, "#{self.class.name}#choices undefined"
        end

        # @param index [Integer]
        # @return [DeltaChoice]
        def choice(index: 0)
          choices[index]
        end

        # @param index [Integer]
        # @return [Part]
        def part(index: 0)
          choice(index:).part
        end

        # @return [Usage]
        def usage
          @usage ||= Usage.new(data: @data['usage']) if @data['usage']
        end

        # @return [String, nil]
        def content
          choice.content
        end

        # @return [Boolean]
        def content?
          choice.content?
        end

        # @return [Array<ToolCall>]
        def tool_call_list
          choice.tool_call_list
        end
      end
    end
  end
end
