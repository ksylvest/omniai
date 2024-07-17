# frozen_string_literal: true

module OmniAI
  class Chat
    # An abstract class that represents audio / image / video and is used for both files and urls.
    class Media < Content
      class TypeError < Error; end

      # @return [Symbol, String]
      attr_accessor :type

      # @param type [String] "audio/flac", "image/jpeg", "video/mpeg", etc.
      def initialize(type)
        super()
        @type = type
      end

      # @return [Boolean]
      def text?
        @type.match?(%r{^text/})
      end

      # @return [Boolean]
      def audio?
        @type.match?(%r{^audio/})
      end

      # @return [Boolean]
      def image?
        @type.match?(%r{^image/})
      end

      # @return [Boolean]
      def video?
        @type.match?(%r{^video/})
      end

      # @return [:video, :audio, :image, :text]
      def kind
        if text? then :text
        elsif audio? then :audio
        elsif image? then :image
        elsif video? then :video
        else
          raise(TypeError, "unsupported type=#{@type}")
        end
      end

      # e.g. "Hello" -> "SGVsbG8h"
      #
      # @return [String]
      def data
        Base64.strict_encode64(fetch!)
      end

      # e.g. "data:text/html;base64,..."
      #
      # @return [String]
      def data_uri
        "data:#{@type};base64,#{data}"
      end

      # @return [String]
      def fetch!
        raise NotImplementedError, "#{self.class}#fetch! undefined"
      end
    end
  end
end
