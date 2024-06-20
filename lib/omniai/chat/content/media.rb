# frozen_string_literal: true

module OmniAI
  class Chat
    module Content
      # An abstract class that represents audio / image / video and is used for both files and urls.
      class Media
        attr_accessor :type

        # @param type [String] "audio/flac", "image/jpeg", "video/mpeg", etc.
        def initialize(type)
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

        # @yield [io]
        def fetch!(&)
          raise NotImplementedError, "#{self.class}#fetch! undefined"
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
      end
    end
  end
end
