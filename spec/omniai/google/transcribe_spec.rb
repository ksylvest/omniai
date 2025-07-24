# frozen_string_literal: true

# rubocop:disable RSpec/SubjectStub, RSpec/VerifiedDoubles
RSpec.describe OmniAI::Google::Transcribe do
  let(:client) { OmniAI::Google::Client.new(api_key: "fake", project_id: "test-project", location_id: "us-central1") }
  let(:model) { described_class::Model::LATEST_SHORT }

  describe ".process!" do
    subject(:transcription) { described_class.process!(path, client:, model:, format:) }

    let(:path) { Pathname.new(File.dirname(__FILE__)).join("..", "..", "fixtures", "greeting.txt") }

    context "with JSON format" do
      let(:format) { described_class::Format::JSON }

      before do
        stub_request(:post, "https://us-central1-speech.googleapis.com/v2/projects/test-project/locations/us-central1/recognizers/_:recognize?key=fake")
          .to_return_json(body: {
            results: [
              {
                alternatives: [
                  {
                    transcript: "The quick brown fox jumps over a lazy dog.",
                    confidence: 0.98,
                  },
                ],
              },
            ],
          })
      end

      it { expect(transcription.text).to eql("The quick brown fox jumps over a lazy dog.") }
    end

    context "with VERBOSE_JSON format" do
      let(:format) { described_class::Format::VERBOSE_JSON }

      before do
        stub_request(:post, "https://us-central1-speech.googleapis.com/v2/projects/test-project/locations/us-central1/recognizers/_:recognize?key=fake")
          .to_return_json(body: {
            results: [
              {
                alternatives: [
                  {
                    transcript: "The quick brown fox jumps over a lazy dog.",
                    confidence: 0.98,
                    words: [
                      { word: "The", startTime: "0s", endTime: "0.1s", confidence: 0.99 },
                      { word: "quick", startTime: "0.1s", endTime: "0.3s", confidence: 0.97 },
                    ],
                  },
                ],
              },
            ],
          })
      end

      it { expect(transcription.text).to eql("The quick brown fox jumps over a lazy dog.") }
    end

    context "with Vertex AI client" do
      let(:client) do
        OmniAI::Google::Client.new(api_key: "fake", project_id: "test-project", location_id: "us-central1",
          host: "https://us-central1-aiplatform.googleapis.com")
      end
      let(:format) { described_class::Format::JSON }

      before do
        stub_request(:post, "https://us-central1-speech.googleapis.com/v2/projects/test-project/locations/us-central1/recognizers/_:recognize?key=fake")
          .to_return_json(body: {
            results: [
              {
                alternatives: [
                  {
                    transcript: "Hello world from Vertex AI.",
                    confidence: 0.95,
                  },
                ],
              },
            ],
          })
      end

      it { expect(transcription.text).to eql("Hello world from Vertex AI.") }
    end

    context "with async recognition needed" do
      let(:format) { described_class::Format::JSON }
      let(:model) { "latest_long" }

      before do
        transcribe_instance = instance_double(described_class)
        allow(described_class).to receive(:new).and_return(transcribe_instance)
        allow(transcribe_instance).to receive(:process!).and_return(
          OmniAI::Transcribe::Transcription.new(text: "Async result", model:, format:)
        )
      end

      it "uses async processing for long models" do
        expect(transcription.text).to eql("Async result")
      end
    end
  end

  describe "#build_config" do
    subject(:transcribe) { described_class.new(path, client:, model:, language:, format:) }

    let(:path) { Pathname.new(File.dirname(__FILE__)).join("..", "..", "fixtures", "greeting.txt") }
    let(:format) { "json" }

    context "with chirp model and no language" do
      let(:model) { "chirp_2" }
      let(:language) { nil }

      it "uses auto language detection" do
        config = transcribe.send(:build_config)
        expect(config[:languageCodes]).to eq ["auto"]
      end
    end

    context "with non-chirp model and no language" do
      let(:model) { "latest_short" }
      let(:language) { nil }

      it "uses multi-language detection" do
        config = transcribe.send(:build_config)
        expect(config[:languageCodes]).to eq %w[en-US es-US]
      end
    end

    context "with specified language" do
      let(:model) { "latest_short" }
      let(:language) { "fr-FR" }

      it "uses specified language" do
        config = transcribe.send(:build_config)
        expect(config[:languageCodes]).to eq ["fr-FR"]
      end
    end

    context "with empty language array" do
      let(:model) { "latest_short" }
      let(:language) { [] }

      it "uses default language codes" do
        config = transcribe.send(:build_config)
        expect(config[:languageCodes]).to eq %w[en-US es-US]
      end
    end

    context "with array of languages including empty strings" do
      let(:model) { "latest_short" }
      let(:language) { ["en-US", "", "fr-FR"] }

      it "filters out empty strings" do
        config = transcribe.send(:build_config)
        expect(config[:languageCodes]).to eq %w[en-US fr-FR]
      end
    end
  end

  describe "#add_audio_data" do
    subject(:transcribe) { described_class.new(io, client:, model:) }

    context "with GCS URI" do
      let(:io) { "gs://bucket/file.mp3" }
      let(:model) { "latest_short" }

      it "adds uri to payload" do
        payload = {}
        transcribe.send(:add_audio_data, payload)
        expect(payload[:uri]).to eq "gs://bucket/file.mp3"
      end
    end

    context "with local file needing GCS upload" do
      let(:io) { "small_file.mp3" }
      let(:model) { "chirp_2" }

      before do
        allow(OmniAI::Google::Bucket).to receive(:process!).and_return("gs://uploaded/file.mp3")
      end

      it "uploads to GCS and adds uri" do
        payload = {}
        transcribe.send(:add_audio_data, payload)
        expect(payload[:uri]).to eq "gs://uploaded/file.mp3"
      end
    end

    context "with small local file" do
      let(:io) { StringIO.new("test content") }
      let(:model) { "latest_short" }

      it "adds base64 content to payload" do
        payload = {}
        transcribe.send(:add_audio_data, payload)
        expect(payload[:content]).to eq Base64.strict_encode64("test content")
      end
    end
  end

  describe "#process_async!" do
    subject(:transcribe) { described_class.new("test.mp3", client:, model: "latest_long") }

    let(:batch_response) do
      instance_double(HTTP::Response).tap do |response|
        allow(response).to receive_messages(status: double(ok?: true), parse: operation_data)
      end
    end

    let(:operation_data) do
      {
        "name" => "projects/test/operations/123",
        "metadata" => {
          "batchRecognizeRequest" => {
            "files" => [{ "uri" => "gs://bucket/uploaded.mp3" }],
          },
        },
      }
    end

    let(:operation_result) { { "done" => true, "response" => {} } }

    before do
      allow(transcribe).to receive_messages(request_batch!: batch_response, poll_operation!: operation_result,
        extract_batch_transcript: { "text" => "Hello world" })
      allow(transcribe).to receive(:cleanup_gcs_file)
    end

    it "processes async transcription successfully" do
      result = transcribe.send(:process_async!)
      expect(result).to be_a(OmniAI::Transcribe::Transcription)
    end

    context "when batch request fails" do
      before do
        failed_response = instance_double(HTTP::Response).tap do |response|
          allow(response).to receive_messages(status: double(ok?: false), body: "Error")
        end
        allow(transcribe).to receive(:request_batch!).and_return(failed_response)
      end

      it "raises HTTPError for failed batch request" do
        expect { transcribe.send(:process_async!) }.to raise_error(OmniAI::HTTPError)
      end
    end

    context "with user-provided GCS URI" do
      subject(:transcribe) { described_class.new("gs://user-bucket/file.mp3", client:, model: "latest_long") }

      before do
        allow(transcribe).to receive_messages(request_batch!: batch_response, poll_operation!: operation_result,
          extract_batch_transcript: { "text" => "Hello world" })
        allow(transcribe).to receive(:cleanup_gcs_file)
      end

      it "does not attempt cleanup for user-provided GCS URIs" do
        transcribe.send(:process_async!)
        expect(transcribe).not_to have_received(:cleanup_gcs_file)
      end
    end
  end

  describe "#needs_async_recognition?" do
    subject(:transcribe) { described_class.new(io, client:, model:) }

    context "when needs_long_form_recognition? is true" do
      let(:io) { "test.mp3" }
      let(:model) { "latest_long" }

      it "returns true" do
        expect(transcribe.send(:needs_async_recognition?)).to be true
      end
    end

    context "when needs_gcs_upload? is true" do
      let(:io) { "test.mp3" }
      let(:model) { "latest_short" }

      before do
        allow(transcribe).to receive(:needs_gcs_upload?).and_return(true)
      end

      it "returns true" do
        expect(transcribe.send(:needs_async_recognition?)).to be true
      end
    end
  end

  describe "#verbose_json_format?" do
    subject(:transcribe) { described_class.new("test.mp3", client:, model: "latest_short", format:) }

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
  end

  describe "#build_verbose_sync_data" do
    subject(:transcribe) { described_class.new("test.mp3", client:, model: "latest_short", format: "verbose_json") }

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
    end
  end

  describe "#build_sync_response_data" do
    subject(:transcribe) { described_class.new("test.mp3", client:, model: "latest_short", format:) }

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

  describe "protected methods" do
    subject(:transcribe) { described_class.new("test.mp3", client:, model: "latest_short") }

    describe "#request!" do
      before do
        stub_request(:post, "https://us-central1-speech.googleapis.com/v2/projects/test-project/locations/us-central1/recognizers/_:recognize?key=fake")
          .to_return(status: 200, body: '{"results": []}')
      end

      it "makes HTTP request to speech API" do
        response = transcribe.send(:request!)
        expect(response.status.code).to eq 200
      end
    end

    describe "#payload" do
      it "builds request payload with config and audio data" do
        payload = transcribe.send(:payload)
        expect(payload).to have_key(:config)
        expect(payload[:config]).to have_key(:model)
        expect(payload[:config][:model]).to eq "latest_short"
      end
    end

    describe "#path" do
      it "builds correct API path" do
        path = transcribe.send(:path)
        expected = "/v2/projects/test-project/locations/us-central1/recognizers/_:recognize"
        expect(path).to eq expected
      end
    end

    describe "#params" do
      it "includes API key when using API key auth" do
        params = transcribe.send(:params)
        expect(params[:key]).to eq "fake"
      end
    end

    describe "#params with credentials auth" do
      subject(:transcribe) { described_class.new("test.mp3", client:, model: "latest_short") }

      let(:client) do
        instance_double(OmniAI::Google::Client).tap do |client|
          allow(client).to receive_messages(api_key: nil, credentials?: true)
        end
      end

      it "excludes API key when using credentials" do
        params = transcribe.send(:params)
        expect(params[:key]).to be_nil
      end
    end
  end
end
# rubocop:enable RSpec/SubjectStub, RSpec/VerifiedDoubles
