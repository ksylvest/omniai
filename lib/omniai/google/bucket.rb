# frozen_string_literal: true

require "google/cloud/storage"

module OmniAI
  module Google
    # Uploads audio files to Google Cloud Storage for transcription.
    class Bucket
      class UploadError < StandardError; end

      # @param client [Client]
      # @param io [IO, String]
      # @param bucket_name [String] optional - bucket name (defaults to project_id-speech-audio)
      def self.process!(client:, io:, bucket_name: nil)
        new(client:, io:, bucket_name:).process!
      end

      # @param client [Client]
      # @param io [File, String]
      # @param bucket_name [String] optional - bucket name
      def initialize(client:, io:, bucket_name: nil)
        @client = client
        @io = io
        @bucket_name = bucket_name || default_bucket_name
      end

      # @raise [UploadError]
      #
      # @return [String] GCS URI (gs://bucket/object)
      def process!
        # Create storage client with same credentials as main client
        credentials = @client.instance_variable_get(:@credentials)
        storage = ::Google::Cloud::Storage.new(
          project_id:,
          credentials:
        )

        # Get bucket (don't auto-create if it doesn't exist)
        bucket = storage.bucket(@bucket_name)
        unless bucket
          raise UploadError, "Bucket '#{@bucket_name}' not found. " \
            "Please create it manually or ensure the service account has access."
        end

        # Generate unique filename
        timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
        random_suffix = SecureRandom.hex(4)
        filename = "audio_#{timestamp}_#{random_suffix}.#{file_extension}"

        # Upload file - create StringIO for binary content
        content = file_content
        if content.is_a?(String) && content.include?("\0")
          # Binary content - wrap in StringIO
          require "stringio"
          content = StringIO.new(content)
        end

        bucket.create_file(content, filename)

        # Return GCS URI
        "gs://#{@bucket_name}/#{filename}"
      rescue ::Google::Cloud::Error => e
        raise UploadError, "Failed to upload to GCS: #{e.message}"
      end

    private

      # @return [String]
      def project_id
        @client.instance_variable_get(:@project_id) ||
          raise(ArgumentError, "project_id is required for GCS upload")
      end

      # @return [String]
      def location_id
        @client.instance_variable_get(:@location_id) || "global"
      end

      # @return [String]
      def default_bucket_name
        "#{project_id}-speech-audio"
      end

      # @return [String]
      def file_content
        case @io
        when String
          # Check if it's a file path or binary content
          if @io.include?("\0") || !File.exist?(@io)
            # It's binary content, return as-is
            @io
          else
            # It's a file path, read the file
            File.read(@io)
          end
        when File, IO, StringIO
          @io.rewind if @io.respond_to?(:rewind)
          @io.read
        else
          raise ArgumentError, "Unsupported input type: #{@io.class}"
        end
      end

      # @return [String]
      def file_extension
        case @io
        when String
          File.extname(@io)[1..] || "wav"
        else
          "wav" # Default extension
        end
      end
    end
  end
end
