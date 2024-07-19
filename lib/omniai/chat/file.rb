# frozen_string_literal: true

module OmniAI
  class Chat
    # A file is media that can be sent to many LLMs.
    class File < Media
      attr_accessor :io

      # @param io [IO, Pathname, String]
      # @param type [Symbol, String] :image, :video, :audio, "audio/flac", "image/jpeg", "video/mpeg", etc.
      def initialize(io, type)
        super(type)
        @io = io
      end

      # @return [String]
      def inspect
        "#<#{self.class} io=#{@io.inspect}>"
      end

      # @return [String]
      def fetch!
        case @io
        when IO then @io.read
        else ::File.binread(@io)
        end
      end

      # @param context [Context]
      # @return [Hash]
      def serialize(context: nil)
        if text?
          content = fetch!
          Text.new("<file>#{filename}: #{content}</file>").serialize(context:)
        else
          serializer = context&.serializers&.[](:file)
          return serializer.call(self, context:) if serializer

          { type: "#{kind}_url", "#{kind}_url": { url: data_uri } }
        end
      end

      # @return [String]
      def filename
        case @io
        when Tempfile, File, String then ::File.basename(@io)
        else 'DATA'
        end
      end
    end
  end
end
