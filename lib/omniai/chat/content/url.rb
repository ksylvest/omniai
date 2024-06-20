# frozen_string_literal: true

module OmniAI
  class Chat
    module Content
      # A url that is either audio / image / video.
      class URL < Media
        attr_accessor :url, :type

        class HTTPError < OmniAI::HTTPError; end

        # @param url [URI, String]
        # @param type [Symbol, String] "audio/flac", "image/jpeg", "video/mpeg", etc.
        def initialize(url, type)
          super(type)
          @url = url
        end

        # @raise [HTTPError]
        #
        # @return [String]
        def fetch!
          response = request!
          String(response.body)
        end

        private

        # @raise [HTTPError]
        #
        # @return [HTTP::Response]
        def request!
          response = HTTP.get(@url)
          raise HTTPError, response.flush unless response.status.success?

          response
        end
      end
    end
  end
end
