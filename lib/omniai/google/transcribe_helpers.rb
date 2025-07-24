# frozen_string_literal: true

module OmniAI
  module Google
    # Helper methods for transcription functionality
    module TranscribeHelpers # rubocop:disable Metrics/ModuleLength
    private

      # @return [String]
      def project_id
        @client.instance_variable_get(:@project_id) ||
          raise(ArgumentError, "project_id is required for transcription")
      end

      # @return [String]
      def location_id
        case @model
        when "chirp_2"
          "us-central1"
        else
          @client.instance_variable_get(:@location_id) || "global"
        end
      end

      # @return [String]
      def speech_endpoint
        location_id == "global" ? "https://speech.googleapis.com" : "https://#{location_id}-speech.googleapis.com"
      end

      # @return [Array<String>, nil]
      def language_codes
        case @language
        when String
          [@language] unless @language.strip.empty?
        when Array
          cleaned = @language.compact.reject(&:empty?)
          cleaned if cleaned.any?
        when nil, ""
          nil # Auto-detect language when not specified
        else
          ["en-US"] # Default to English (multi-language only supported in global/us/eu locations)
        end
      end

      # @param input [String, Pathname, File, IO]
      # @return [String] Base64 encoded audio content
      def encode_audio(input)
        case input
        when String
          if File.exist?(input)
            Base64.strict_encode64(File.read(input))
          else
            input # Assume it's already base64 encoded
          end
        when Pathname, File, IO, StringIO
          Base64.strict_encode64(input.read)
        else
          raise ArgumentError, "Unsupported input type: #{input.class}"
        end
      end

      # @return [Boolean]
      def needs_gcs_upload?
        return false if @io.is_a?(String) && @io.start_with?("gs://")

        file_size = calculate_file_size
        # Force GCS upload for files > 10MB or if using long models for longer audio
        file_size > 10_000_000 || needs_long_form_recognition?
      end

      # @return [Boolean]
      def needs_long_form_recognition?
        # Use long-form models for potentially longer audio files
        return true if @model&.include?("long")

        # Chirp models process speech in larger chunks and prefer BatchRecognize
        return true if @model&.include?("chirp")

        # For large files, assume they might be longer than 60 seconds
        # Approximate: files larger than 1MB might be longer than 60 seconds
        calculate_file_size > 1_000_000
      end

      # @return [Integer]
      def calculate_file_size
        case @io
        when String
          File.exist?(@io) ? File.size(@io) : 0
        when File, IO, StringIO
          @io.respond_to?(:size) ? @io.size : 0
        else
          0
        end
      end

      # @return [Hash]
      def build_config
        config = {
          model: @model,
          autoDecodingConfig: {},
        }

        # Only include languageCodes if specified and non-empty (omit for auto-detection)
        lang_codes = language_codes
        config[:languageCodes] = if lang_codes&.any?
                                   lang_codes
                                 else
                                   # Handle language detection based on model capabilities
                                   default_language_codes
                                 end

        features = build_features
        config[:features] = features unless features.empty?

        config.merge!(OmniAI::Google.config.transcribe_options)

        config
      end

      # @return [Array<String>] Default language codes based on model
      def default_language_codes
        if @model&.include?("chirp")
          # Chirp models use "auto" for automatic language detection
          ["auto"]
        else
          # Other models use multiple languages for auto-detection
          %w[en-US es-US]
        end
      end

      # @return [Hash]
      def build_features
        case @format
        when "verbose_json"
          {
            enableAutomaticPunctuation: true,
            enableWordTimeOffsets: true,
            enableWordConfidence: true,
          }
        when "json"
          { enableAutomaticPunctuation: true }
        else
          {}
        end
      end

      # @param payload_data [Hash]
      def add_audio_data(payload_data)
        if @io.is_a?(String) && @io.start_with?("gs://")
          payload_data[:uri] = @io
        elsif needs_gcs_upload?
          gcs_uri = Bucket.process!(client: @client, io: @io)
          payload_data[:uri] = gcs_uri
        else
          payload_data[:content] = encode_audio(@io)
        end
      end

      # @return [Hash] Payload for batch recognition
      def batch_payload
        config = build_config

        # Get audio URI for batch processing
        audio_uri = if @io.is_a?(String) && @io.start_with?("gs://")
                      @io
                    else
                      # Force GCS upload for batch recognition
                      Bucket.process!(client: @client, io: @io)
                    end

        {
          config:,
          files: [{ uri: audio_uri }],
          recognitionOutputConfig: {
            inlineResponseConfig: {},
          },
        }
      end

      # @param operation_name [String]
      # @raise [HTTPError]
      #
      # @return [Hash]
      def poll_operation!(operation_name)
        endpoint = speech_endpoint
        connection = HTTP.persistent(endpoint)
          .timeout(connect: @client.timeout, write: @client.timeout, read: @client.timeout)
          .accept(:json)

        # Add authentication if using credentials
        connection = connection.auth("Bearer #{@client.send(:auth).split.last}") if @client.credentials?

        max_attempts = calculate_max_polling_attempts
        attempt = 0

        loop do
          attempt += 1

          raise StandardError, "Operation timed out after #{max_attempts * 15} seconds" if attempt > max_attempts

          operation_response = connection.get("/v2/#{operation_name}", params: operation_params)

          raise HTTPError, operation_response unless operation_response.status.ok?

          operation_data = operation_response.parse

          # Check for errors
          if operation_data["error"]
            error_message = operation_data.dig("error", "message") || "Unknown error"
            raise HTTPError, "Operation failed: #{error_message}"
          end

          # Check if done
          return operation_data if operation_data["done"]

          # Wait before polling again
          sleep(15)
        end
      end

      # @return [HTTP::Response]
      def request_batch!
        endpoint = speech_endpoint
        connection = HTTP.persistent(endpoint)
          .timeout(connect: @client.timeout, write: @client.timeout, read: @client.timeout)
          .accept(:json)

        # Add authentication if using credentials
        connection = connection.auth("Bearer #{@client.send(:auth).split.last}") if @client.credentials?

        connection.post(batch_path, params: operation_params, json: batch_payload)
      end

      # @return [String]
      def batch_path
        # Use batchRecognize endpoint for async recognition
        recognizer_path = "projects/#{project_id}/locations/#{location_id}/recognizers/#{recognizer_name}"
        "/v2/#{recognizer_path}:batchRecognize"
      end

      # @return [Hash]
      def operation_params
        { key: (@client.api_key unless @client.credentials?) }.compact
      end

      # @return [String]
      def recognizer_name
        # Always use the default recognizer - the model is specified in the config
        "_"
      end

      # @param result [Hash] Operation result from batch recognition
      # @return [Hash] Data formatted for OmniAI::Transcribe::Transcription.parse
      def extract_batch_transcript(result)
        batch_results = result.dig("response", "results")
        return empty_transcript_data unless batch_results

        file_result = batch_results.values.first
        return empty_transcript_data unless file_result

        transcript_segments = file_result.dig("transcript", "results")
        return empty_transcript_data unless transcript_segments&.any?

        build_transcript_data(transcript_segments, file_result)
      end

      # @return [Hash]
      def empty_transcript_data
        { "text" => "" }
      end

      # @param transcript_segments [Array]
      # @param file_result [Hash]
      # @return [Hash]
      def build_transcript_data(transcript_segments, file_result)
        transcript_text = extract_transcript_text(transcript_segments)
        result_data = { "text" => transcript_text }

        add_duration_if_available(result_data, file_result)
        add_segments_if_verbose(result_data, transcript_segments)

        result_data
      end

      # @param transcript_segments [Array]
      # @return [String]
      def extract_transcript_text(transcript_segments)
        text_segments = transcript_segments.map do |segment|
          segment.dig("alternatives", 0, "transcript")
        end.compact

        text_segments.join(" ")
      end

      # @param result_data [Hash]
      # @param file_result [Hash]
      def add_duration_if_available(result_data, file_result)
        duration = file_result.dig("metadata", "totalBilledDuration")
        result_data["duration"] = parse_duration(duration) if duration
      end

      # @param result_data [Hash]
      # @param transcript_segments [Array]
      def add_segments_if_verbose(result_data, transcript_segments)
        result_data["segments"] = build_segments(transcript_segments) if @format == "verbose_json"
      end

      # @param duration_string [String] Duration in Google's format (e.g., "123.456s")
      # @return [Float] Duration in seconds
      def parse_duration(duration_string)
        return nil unless duration_string

        duration_string.to_s.sub(/s$/, "").to_f
      end

      # @param segments [Array] Transcript segments from Google API
      # @return [Array<Hash>] Segments formatted for base class
      def build_segments(segments)
        segments.map.with_index do |segment, index|
          alternative = segment.dig("alternatives", 0)
          next unless alternative

          segment_data = {
            "id" => index,
            "text" => alternative["transcript"],
            "start" => calculate_segment_start(segments, index),
            "end" => parse_duration(segment["resultEndOffset"]),
            "confidence" => alternative["confidence"],
          }

          # Words removed - segments provide sufficient granularity for most use cases

          segment_data
        end.compact
      end

      # @param segments [Array] All segments
      # @param index [Integer] Current segment index
      # @return [Float] Start time estimated from previous segment end
      def calculate_segment_start(segments, index)
        return 0.0 if index.zero?

        prev_segment = segments[index - 1]
        parse_duration(prev_segment["resultEndOffset"]) || 0.0
      end

      # @param response [HTTP::Response]
      # @raise [HTTPError]
      def handle_sync_response_errors(response)
        return if response.status.ok?

        error_data = parse_error_data(response)
        raise_timeout_error(response) if timeout_error?(error_data)
        raise HTTPError, response
      end

      # @param response [HTTP::Response]
      # @return [Hash]
      def parse_error_data(response)
        response.parse
      rescue StandardError
        {}
      end

      # @param error_data [Hash]
      # @return [Boolean]
      def timeout_error?(error_data)
        error_data.dig("error", "message")&.include?("60 seconds")
      end

      # @param response [HTTP::Response]
      # @raise [HTTPError]
      def raise_timeout_error(response)
        raise HTTPError, (response.tap do |r|
          r.instance_variable_set(:@body, "Audio file exceeds 60-second limit for direct upload. " \
            "Use a long-form model (e.g., 'latest_long') or upload to GCS first. " \
            "Original error: #{response.flush}")
        end)
      end

      # @param data [Hash]
      # @param transcript [String]
      # @return [Hash]
      def build_sync_response_data(data, transcript)
        return { "text" => transcript } unless verbose_json_format?(data)

        build_verbose_sync_data(data, transcript)
      end

      # @param data [Hash]
      # @return [Boolean]
      def verbose_json_format?(data)
        @format == "verbose_json" &&
          data["results"]&.any? &&
          data["results"][0]["alternatives"]&.any?
      end

      # @param data [Hash]
      # @param transcript [String]
      # @return [Hash]
      def build_verbose_sync_data(data, transcript)
        alternative = data["results"][0]["alternatives"][0]
        {
          "text" => transcript,
          "segments" => [{
            "id" => 0,
            "text" => transcript,
            "start" => 0.0,
            "end" => nil,
            "confidence" => alternative["confidence"],
          }],
        }
      end

      # @param gcs_uri [String] GCS URI to delete (e.g., "gs://bucket/file.mp3")
      def cleanup_gcs_file(gcs_uri)
        return unless valid_gcs_uri?(gcs_uri)

        bucket_name, object_name = parse_gcs_uri(gcs_uri)
        return unless bucket_name && object_name

        delete_gcs_object(bucket_name, object_name, gcs_uri)
      end

      # @param gcs_uri [String]
      # @return [Boolean]
      def valid_gcs_uri?(gcs_uri)
        gcs_uri&.start_with?("gs://")
      end

      # @param gcs_uri [String]
      # @return [Array<String>] [bucket_name, object_name]
      def parse_gcs_uri(gcs_uri)
        uri_parts = gcs_uri.sub("gs://", "").split("/", 2)
        [uri_parts[0], uri_parts[1]]
      end

      # @param bucket_name [String]
      # @param object_name [String]
      # @param gcs_uri [String]
      def delete_gcs_object(bucket_name, object_name, gcs_uri)
        storage = create_storage_client
        bucket = storage.bucket(bucket_name)
        return unless bucket

        file = bucket.file(object_name)
        file&.delete
      rescue ::Google::Cloud::Error => e
        @client.logger&.warn("Failed to cleanup GCS file #{gcs_uri}: #{e.message}")
      end

      # @return [Google::Cloud::Storage]
      def create_storage_client
        credentials = @client.instance_variable_get(:@credentials)
        ::Google::Cloud::Storage.new(project_id:, credentials:)
      end

      # @return [Integer]
      def calculate_max_polling_attempts
        file_size_bytes = calculate_file_size
        assumed_bitrate_bps = 48_000
        estimated_duration_seconds = (file_size_bytes * 8.0) / assumed_bitrate_bps
        estimated_processing_seconds = estimated_duration_seconds * 0.3
        total_wait_seconds = estimated_processing_seconds + 90
        final_wait_seconds = total_wait_seconds.clamp(180, 10_800)
        (final_wait_seconds / 15).ceil
      end
    end
  end
end
