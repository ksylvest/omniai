# frozen_string_literal: true

module OmniAI
  class Chat
    module Response
      # A chunk returned by the API.
      class Chunk < Resource
        # @return [String]
        def inspect
          "#<#{self.class.name} id=#{id.inspect} model=#{model.inspect} choices=#{choices.inspect}>"
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

        # @return [Array<OmniAI::Chat::Response::DeltaChoice>]
        def choices
          @choices ||= @data['choices'].map { |data| DeltaChoice.new(data:) }
        end

        # @param index [Integer]
        # @return [OmniAI::Chat::Response::DeltaChoice]
        def choice(index: 0)
          choices[index]
        end
      end
    end
  end
end
