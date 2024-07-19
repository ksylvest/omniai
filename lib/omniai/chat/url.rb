# frozen_string_literal: true

module OmniAI
  class Chat
    # A URL that is media that can be sent to many LLMs.
    class URL < Media
      # @return [URI, String]
      attr_accessor :uri

      class FetchError < HTTPError; end

      # @param uri [URI, String] "https://example.com/cat.jpg"
      # @param type [Symbol, String] "audio/flac", "image/jpeg", "video/mpeg", :audi, :image, :video, etc.
      def initialize(uri, type = nil)
        super(type)
        @uri = uri
      end

      # @return [String]
      def inspect
        "#<#{self.class} uri=#{@uri.inspect}>"
      end

      # @param data [Hash]
      def self.deserialize(data, context: nil)
        deserialize = context&.deserializers&.[](:url)
        return deserialize.call(data, context:) if deserialize

        type = /(?<type>\w+)_url/.match(data['type'])[:type]
        uri = data["#{type}_url"]['url']

        new(uri, type)
      end

      # @param context [Context] optional
      #
      # @return [Hash]
      def serialize(context: nil)
        if text?
          content = fetch!
          Text.new("<file>#{filename}: #{content}</file>").serialize(context:)
        else
          serializer = context&.serializers&.[](:url)
          return serializer.call(self, context:) if serializer

          {
            type: "#{kind}_url",
            "#{kind}_url": { url: @uri },
          }
        end
      end

      # @raise [FetchError]
      #
      # @return [String]
      def fetch!
        response = request!
        String(response.body)
      end

      # @return [String]
      def filename
        ::File.basename(@uri)
      end

      protected

      # @raise [FetchError]
      #
      # @return [HTTP::Response]
      def request!
        response = HTTP.follow.get(@uri)
        raise FetchError, response.flush unless response.status.success?

        response
      end
    end
  end
end
