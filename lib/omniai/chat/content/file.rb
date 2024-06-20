# frozen_string_literal: true

module OmniAI
  class Chat
    module Content
      # A file that is either audio / image / video.
      class File < Media
        attr_accessor :io

        # @param io [IO, Pathname, String]
        # @param type [Symbol, String] :image, :video, :audio, "audio/flac", "image/jpeg", "video/mpeg", etc.
        def initialize(io, type)
          super(type)
          @io = io
        end

        # @return [String]
        def fetch!
          case @io
          when IO then @io.read
          else ::File.binread(@io)
          end
        end
      end
    end
  end
end
