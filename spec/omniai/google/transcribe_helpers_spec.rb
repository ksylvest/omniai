# frozen_string_literal: true

# rubocop:disable RSpec/SubjectStub, RSpec/VerifiedDoubles
RSpec.describe OmniAI::Google::TranscribeHelpers do
  subject(:transcribe) { transcribe_class.new("test.mp3", client:, model: "latest_short") }

  let(:client) { OmniAI::Google::Client.new(api_key: "fake", project_id: "test-project", location_id: "us-central1") }
  let(:transcribe_class) do
    Class.new do
      include OmniAI::Google::TranscribeHelpers

      def initialize(io, client:, model:, language: nil, format: nil)
        @io = io
        @client = client
        @model = model
        @language = language
        @format = format
      end
    end
  end

  describe "#project_id" do
    context "when project_id is available" do
      it "returns the project_id" do
        expect(transcribe.send(:project_id)).to eq "test-project"
      end
    end

    context "when project_id is missing" do
      let(:client) do
        OmniAI::Google::Client.new(api_key: "fake", location_id: "us-central1")
      end

      it "raises ArgumentError" do
        expect { transcribe.send(:project_id) }
          .to raise_error(ArgumentError, /project_id is required/)
      end
    end
  end

  describe "#location_id" do
    context "when location_id is specified" do
      it "returns the specified location_id" do
        expect(transcribe.send(:location_id)).to eq "us-central1"
      end
    end

    context "when location_id is not specified" do
      let(:client) do
        OmniAI::Google::Client.new(api_key: "fake", project_id: "test-project")
      end

      it "returns global as default" do
        expect(transcribe.send(:location_id)).to eq "global"
      end
    end
  end

  describe "#speech_endpoint" do
    context "with global location" do
      let(:client) { OmniAI::Google::Client.new(api_key: "fake", project_id: "test-project", location_id: "global") }

      it "returns global speech endpoint" do
        endpoint = transcribe.send(:speech_endpoint)
        expect(endpoint).to eq "https://speech.googleapis.com"
      end
    end

    context "with regional location" do
      let(:client) do
        OmniAI::Google::Client.new(api_key: "fake", project_id: "test-project", location_id: "us-central1")
      end

      it "returns regional speech endpoint" do
        endpoint = transcribe.send(:speech_endpoint)
        expect(endpoint).to eq "https://us-central1-speech.googleapis.com"
      end
    end
  end

  describe "#language_codes" do
    subject(:transcribe) { transcribe_class.new("test.mp3", client:, model: "latest_short", language:) }

    context "with string language" do
      let(:language) { "fr-FR" }

      it "returns array with single language" do
        codes = transcribe.send(:language_codes)
        expect(codes).to eq ["fr-FR"]
      end
    end

    context "with empty string language" do
      let(:language) { "" }

      it "returns nil for empty string" do
        codes = transcribe.send(:language_codes)
        expect(codes).to be_nil
      end
    end

    context "with array of languages" do
      let(:language) { ["en-US", "es-US", ""] }

      it "returns cleaned array" do
        codes = transcribe.send(:language_codes)
        expect(codes).to eq %w[en-US es-US]
      end
    end

    context "with empty array" do
      let(:language) { [] }

      it "returns nil for empty array" do
        codes = transcribe.send(:language_codes)
        expect(codes).to be_nil
      end
    end

    context "with nil language" do
      let(:language) { nil }

      it "returns nil" do
        codes = transcribe.send(:language_codes)
        expect(codes).to be_nil
      end
    end

    context "with unsupported type" do
      let(:language) { 12_345 }

      it "returns default English" do
        codes = transcribe.send(:language_codes)
        expect(codes).to eq ["en-US"]
      end
    end
  end

  describe "#encode_audio" do
    context "with file path" do
      let(:file_path) { Pathname.new(File.dirname(__FILE__)).join("..", "..", "fixtures", "greeting.txt").to_s }

      it "encodes file content as base64" do
        result = transcribe.send(:encode_audio, file_path)
        expect(result).to be_a(String)
        expect(result.length).to be > 0
      end
    end

    context "with StringIO object" do
      let(:io) { StringIO.new("test content") }

      it "encodes StringIO content as base64" do
        result = transcribe.send(:encode_audio, io)
        expect(result).to eq Base64.strict_encode64("test content")
      end
    end

    context "with already encoded string" do
      let(:input) { "already_encoded_content" }

      it "returns the string as-is when file doesn't exist" do
        result = transcribe.send(:encode_audio, input)
        expect(result).to eq "already_encoded_content"
      end
    end

    context "with unsupported input type" do
      let(:input) { 12_345 }

      it "raises ArgumentError for unsupported type" do
        expect { transcribe.send(:encode_audio, input) }.to raise_error(ArgumentError, /Unsupported input type/)
      end
    end
  end

  describe "#needs_gcs_upload?" do
    subject(:transcribe) { transcribe_class.new(io, client:, model:) }

    context "with GCS URI" do
      let(:io) { "gs://bucket/file.mp3" }
      let(:model) { "latest_short" }

      it "returns false for existing GCS URIs" do
        expect(transcribe.send(:needs_gcs_upload?)).to be false
      end
    end

    context "with chirp model" do
      let(:io) { "small_file.mp3" }
      let(:model) { "chirp_2" }

      it "returns true for chirp models (needs long form)" do
        expect(transcribe.send(:needs_gcs_upload?)).to be true
      end
    end
  end

  describe "#needs_long_form_recognition?" do
    subject(:transcribe) { transcribe_class.new("test.mp3", client:, model:) }

    context "with chirp_2 model" do
      let(:model) { "chirp_2" }

      it "returns true for chirp models" do
        expect(transcribe.send(:needs_long_form_recognition?)).to be true
      end
    end

    context "with chirp model" do
      let(:model) { "chirp" }

      it "returns true for chirp models" do
        expect(transcribe.send(:needs_long_form_recognition?)).to be true
      end
    end

    context "with latest_long model" do
      let(:model) { "latest_long" }

      it "returns true for long models" do
        expect(transcribe.send(:needs_long_form_recognition?)).to be true
      end
    end

    context "with latest_short model" do
      let(:model) { "latest_short" }

      it "returns false for short models with small files" do
        expect(transcribe.send(:needs_long_form_recognition?)).to be false
      end
    end
  end

  describe "#calculate_file_size" do
    subject(:transcribe) { transcribe_class.new(io, client:, model: "latest_short") }

    context "with file path" do
      let(:io) { Pathname.new(File.dirname(__FILE__)).join("..", "..", "fixtures", "greeting.txt").to_s }

      it "returns file size for valid path" do
        expect(transcribe.send(:calculate_file_size)).to be > 0
      end
    end

    context "with StringIO object" do
      let(:io) { StringIO.new("test content") }

      it "returns size from StringIO object" do
        expect(transcribe.send(:calculate_file_size)).to eq io.size
      end
    end

    context "with invalid input" do
      let(:io) { "nonexistent_file.mp3" }

      it "returns 0 for nonexistent files" do
        expect(transcribe.send(:calculate_file_size)).to eq 0
      end
    end
  end

  describe "#default_language_codes" do
    subject(:transcribe) { transcribe_class.new("test.mp3", client:, model:) }

    context "with chirp_2 model" do
      let(:model) { "chirp_2" }

      it "returns auto for chirp models" do
        expect(transcribe.send(:default_language_codes)).to eq ["auto"]
      end
    end

    context "with chirp model" do
      let(:model) { "chirp" }

      it "returns auto for chirp models" do
        expect(transcribe.send(:default_language_codes)).to eq ["auto"]
      end
    end

    context "with latest_short model" do
      let(:model) { "latest_short" }

      it "returns multi-language codes for non-chirp models" do
        expect(transcribe.send(:default_language_codes)).to eq %w[en-US es-US]
      end
    end

    context "with latest_long model" do
      let(:model) { "latest_long" }

      it "returns multi-language codes for non-chirp models" do
        expect(transcribe.send(:default_language_codes)).to eq %w[en-US es-US]
      end
    end
  end

  describe "#build_features" do
    subject(:transcribe) { transcribe_class.new("test.mp3", client:, model: "latest_short", format:) }

    context "with verbose_json format" do
      let(:format) { "verbose_json" }

      it "enables detailed features" do
        features = transcribe.send(:build_features)
        expect(features[:enableAutomaticPunctuation]).to be true
        expect(features[:enableWordTimeOffsets]).to be true
        expect(features[:enableWordConfidence]).to be true
      end
    end

    context "with json format" do
      let(:format) { "json" }

      it "enables basic features" do
        features = transcribe.send(:build_features)
        expect(features[:enableAutomaticPunctuation]).to be true
        expect(features[:enableWordTimeOffsets]).to be_nil
      end
    end

    context "with default format" do
      let(:format) { nil }

      it "returns empty features hash" do
        features = transcribe.send(:build_features)
        expect(features).to eq({})
      end
    end
  end

  describe "#parse_duration" do
    it "parses duration with seconds suffix" do
      expect(transcribe.send(:parse_duration, "123.456s")).to eq 123.456
    end

    it "parses duration without suffix" do
      expect(transcribe.send(:parse_duration, "123.456")).to eq 123.456
    end

    it "returns nil for nil input" do
      expect(transcribe.send(:parse_duration, nil)).to be_nil
    end

    it "returns 0.0 for empty input" do
      expect(transcribe.send(:parse_duration, "")).to eq 0.0
    end
  end

  describe "#valid_gcs_uri?" do
    it "returns true for valid GCS URI" do
      expect(transcribe.send(:valid_gcs_uri?, "gs://bucket/file.mp3")).to be true
    end

    it "returns false for invalid URI" do
      expect(transcribe.send(:valid_gcs_uri?, "http://example.com")).to be false
    end

    it "returns false for nil" do
      expect(transcribe.send(:valid_gcs_uri?, nil)).to be_falsy
    end
  end

  describe "#parse_gcs_uri" do
    it "parses GCS URI correctly" do
      bucket, object = transcribe.send(:parse_gcs_uri, "gs://my-bucket/path/to/file.mp3")
      expect(bucket).to eq "my-bucket"
      expect(object).to eq "path/to/file.mp3"
    end

    it "handles URI without path" do
      bucket, object = transcribe.send(:parse_gcs_uri, "gs://my-bucket/file.mp3")
      expect(bucket).to eq "my-bucket"
      expect(object).to eq "file.mp3"
    end
  end

  describe "#timeout_error?" do
    it "returns true for 60 seconds timeout error" do
      error_data = { "error" => { "message" => "Request exceeded 60 seconds limit" } }
      expect(transcribe.send(:timeout_error?, error_data)).to be true
    end

    it "returns false for other errors" do
      error_data = { "error" => { "message" => "Invalid request" } }
      expect(transcribe.send(:timeout_error?, error_data)).to be false
    end

    it "returns false for missing error message" do
      error_data = { "error" => {} }
      expect(transcribe.send(:timeout_error?, error_data)).to be_falsy
    end
  end

  describe "#cleanup_gcs_file" do
    context "with invalid URI" do
      let(:gcs_uri) { "invalid-uri" }

      it "does nothing for invalid URI" do
        expect { transcribe.send(:cleanup_gcs_file, gcs_uri) }.not_to raise_error
      end
    end

    context "with nil URI" do
      let(:gcs_uri) { nil }

      it "does nothing for nil URI" do
        expect { transcribe.send(:cleanup_gcs_file, gcs_uri) }.not_to raise_error
      end
    end
  end

  describe "#batch_payload" do
    subject(:transcribe) { transcribe_class.new(io, client:, model: "latest_long") }

    context "with GCS URI" do
      let(:io) { "gs://bucket/file.mp3" }

      it "uses existing GCS URI" do
        payload = transcribe.send(:batch_payload)
        expect(payload[:files][0][:uri]).to eq "gs://bucket/file.mp3"
      end
    end

    context "with local file" do
      let(:io) { "test.mp3" }

      before do
        allow(OmniAI::Google::Bucket).to receive(:process!).and_return("gs://uploaded/file.mp3")
      end

      it "uploads file and uses returned URI" do
        payload = transcribe.send(:batch_payload)
        expect(payload[:files][0][:uri]).to eq "gs://uploaded/file.mp3"
      end
    end
  end

  describe "#batch_path" do
    it "builds correct batch recognition path" do
      path = transcribe.send(:batch_path)
      expected = "/v2/projects/test-project/locations/us-central1/recognizers/_:batchRecognize"
      expect(path).to eq expected
    end
  end

  describe "#operation_params" do
    it "includes API key when using API key auth" do
      params = transcribe.send(:operation_params)
      expect(params[:key]).to eq "fake"
    end

    context "with credentials auth" do
      let(:client) do
        instance_double(OmniAI::Google::Client).tap do |client|
          allow(client).to receive_messages(api_key: nil, credentials?: true)
        end
      end

      it "excludes API key when using credentials" do
        params = transcribe.send(:operation_params)
        expect(params[:key]).to be_nil
      end
    end
  end

  describe "#recognizer_name" do
    it "returns default recognizer name" do
      expect(transcribe.send(:recognizer_name)).to eq "_"
    end
  end

  describe "#build_config" do
    subject(:transcribe) do
      transcribe_class.new("test.mp3", client:, model: "latest_short", language: nil, format: "json")
    end

    context "when features are empty" do
      before do
        allow(transcribe).to receive(:build_features).and_return({})
      end

      it "does not include features in config" do
        config = transcribe.send(:build_config)
        expect(config).not_to have_key(:features)
      end
    end

    context "when features are present" do
      before do
        allow(transcribe).to receive(:build_features).and_return({ enableAutomaticPunctuation: true })
      end

      it "includes features in config" do
        config = transcribe.send(:build_config)
        expect(config[:features]).to eq({ enableAutomaticPunctuation: true })
      end
    end
  end

  describe "#verbose_json_format?" do
    subject(:transcribe) { transcribe_class.new("test.mp3", client:, model: "latest_short", format:) }

    let(:data) do
      {
        "results" => [
          { "alternatives" => [{ "transcript" => "test" }] },
        ],
      }
    end

    context "with verbose_json format and valid data" do
      let(:format) { "verbose_json" }

      it "returns true" do
        expect(transcribe.send(:verbose_json_format?, data)).to be true
      end
    end

    context "with json format" do
      let(:format) { "json" }

      it "returns false" do
        expect(transcribe.send(:verbose_json_format?, data)).to be false
      end
    end

    context "with verbose_json format but empty results" do
      let(:format) { "verbose_json" }
      let(:data) { { "results" => [] } }

      it "returns false" do
        expect(transcribe.send(:verbose_json_format?, data)).to be false
      end
    end

    context "with verbose_json format but missing alternatives" do
      let(:format) { "verbose_json" }
      let(:data) { { "results" => [{}] } }

      it "returns false" do
        expect(transcribe.send(:verbose_json_format?, data)).to be_falsy
      end
    end
  end

  describe "#build_verbose_sync_data" do
    subject(:transcribe) { transcribe_class.new("test.mp3", client:, model: "latest_short", format: "verbose_json") }

    let(:data) do
      {
        "results" => [
          {
            "alternatives" => [
              { "transcript" => "Hello world", "confidence" => 0.95 },
            ],
          },
        ],
      }
    end

    it "builds verbose sync response data" do
      result = transcribe.send(:build_verbose_sync_data, data, "Hello world")
      expect(result["text"]).to eq "Hello world"
      expect(result["segments"]).to be_an(Array)
      expect(result["segments"].first["confidence"]).to eq 0.95
      expect(result["segments"].first["start"]).to eq 0.0
      expect(result["segments"].first["end"]).to be_nil
      expect(result["segments"].first["id"]).to eq 0
    end
  end

  describe "#build_sync_response_data" do
    subject(:transcribe) { transcribe_class.new("test.mp3", client:, model: "latest_short", format:) }

    context "with verbose_json format" do
      let(:format) { "verbose_json" }
      let(:data) do
        {
          "results" => [
            { "alternatives" => [{ "transcript" => "test", "confidence" => 0.9 }] },
          ],
        }
      end

      it "returns verbose data" do
        result = transcribe.send(:build_sync_response_data, data, "test")
        expect(result["segments"]).to be_an(Array)
      end
    end

    context "with json format" do
      let(:format) { "json" }
      let(:data) { { "results" => [] } }

      it "returns simple data" do
        result = transcribe.send(:build_sync_response_data, data, "test")
        expect(result).to eq({ "text" => "test" })
      end
    end
  end

  describe "edge case coverage" do
    subject(:transcribe) do
      transcribe_class.new("test.mp3", client:, model: "latest_short", language: nil, format: "json")
    end

    describe "language handling with whitespace" do
      subject(:transcribe) { transcribe_class.new("test.mp3", client:, model: "latest_short", language: "  en-US  ") }

      it "handles string with whitespace" do
        codes = transcribe.send(:language_codes)
        expect(codes).to eq ["  en-US  "]
      end
    end

    describe "file handling edge cases" do
      it "handles Pathname input for encode_audio" do
        path = Pathname.new(File.dirname(__FILE__)).join("..", "..", "fixtures", "greeting.txt")
        result = transcribe.send(:encode_audio, path)
        expect(result).to be_a(String)
      end

      it "handles File input for encode_audio" do
        file_path = Pathname.new(File.dirname(__FILE__)).join("..", "..", "fixtures", "greeting.txt")
        File.open(file_path, "r") do |file|
          result = transcribe.send(:encode_audio, file)
          expect(result).to be_a(String)
        end
      end
    end

    describe "duration parsing edge cases" do
      it "handles integer input" do
        expect(transcribe.send(:parse_duration, 123)).to eq 123.0
      end

      it "handles string without 's' suffix" do
        expect(transcribe.send(:parse_duration, "45.67")).to eq 45.67
      end
    end

    describe "file size calculation for different IO types" do
      it "handles IO object without size method" do
        io_object = double("IO")
        allow(io_object).to receive(:respond_to?).with(:size).and_return(false)
        transcribe_with_io = transcribe_class.new(io_object, client:, model: "latest_short")
        expect(transcribe_with_io.send(:calculate_file_size)).to eq 0
      end
    end
  end
end
# rubocop:enable RSpec/SubjectStub, RSpec/VerifiedDoubles
