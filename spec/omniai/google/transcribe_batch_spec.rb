# frozen_string_literal: true

RSpec.describe OmniAI::Google::Transcribe do
  let(:client) { OmniAI::Google::Client.new(api_key: "fake", project_id: "test-project", location_id: "us-central1") }

  describe "#extract_batch_transcript" do
    subject(:transcribe) { described_class.new("test.mp3", client:, model:, format:) }

    context "with successful batch result" do
      let(:model) { "latest_long" }
      let(:format) { "json" }
      let(:batch_result) do
        {
          "response" => {
            "results" => {
              "gs://bucket/file.mp3" => {
                "transcript" => {
                  "results" => [
                    {
                      "alternatives" => [
                        {
                          "transcript" => "Hello world",
                          "confidence" => 0.95,
                        },
                      ],
                      "resultEndOffset" => "5.0s",
                    },
                  ],
                },
                "metadata" => {
                  "totalBilledDuration" => "5.0s",
                },
              },
            },
          },
        }
      end

      it "extracts transcript text" do
        result = transcribe.send(:extract_batch_transcript, batch_result)
        expect(result["text"]).to eq "Hello world"
      end

      it "extracts duration" do
        result = transcribe.send(:extract_batch_transcript, batch_result)
        expect(result["duration"]).to eq 5.0
      end
    end

    context "with verbose_json format" do
      let(:model) { "latest_long" }
      let(:format) { "verbose_json" }
      let(:batch_result) do
        {
          "response" => {
            "results" => {
              "gs://bucket/file.mp3" => {
                "transcript" => {
                  "results" => [
                    {
                      "alternatives" => [
                        {
                          "transcript" => "Hello world",
                          "confidence" => 0.95,
                        },
                      ],
                      "resultEndOffset" => "5.0s",
                    },
                  ],
                },
                "metadata" => {
                  "totalBilledDuration" => "5.0s",
                },
              },
            },
          },
        }
      end

      it "includes segments for verbose format" do
        result = transcribe.send(:extract_batch_transcript, batch_result)
        expect(result["segments"]).to be_an(Array)
        expect(result["segments"].first["text"]).to eq "Hello world"
        expect(result["segments"].first["confidence"]).to eq 0.95
      end
    end

    context "with empty result" do
      let(:model) { "latest_long" }
      let(:format) { "json" }
      let(:batch_result) { {} }

      it "returns empty text" do
        result = transcribe.send(:extract_batch_transcript, batch_result)
        expect(result["text"]).to eq ""
      end
    end

    context "with missing transcript results" do
      let(:model) { "latest_long" }
      let(:format) { "json" }
      let(:batch_result) do
        {
          "response" => {
            "results" => {
              "gs://bucket/file.mp3" => {
                "metadata" => {
                  "totalBilledDuration" => "5.0s",
                },
              },
            },
          },
        }
      end

      it "returns empty text when no transcript" do
        result = transcribe.send(:extract_batch_transcript, batch_result)
        expect(result["text"]).to eq ""
      end
    end
  end

  describe "#build_segments" do
    subject(:transcribe) { described_class.new("test.mp3", client:, model: "latest_long", format: "verbose_json") }

    let(:segments) do
      [
        {
          "alternatives" => [
            {
              "transcript" => "Hello",
              "confidence" => 0.95,
            },
          ],
          "resultEndOffset" => "2.5s",
        },
        {
          "alternatives" => [
            {
              "transcript" => "world",
              "confidence" => 0.90,
            },
          ],
          "resultEndOffset" => "5.0s",
        },
      ]
    end

    it "builds segments with correct structure" do
      result = transcribe.send(:build_segments, segments)
      expect(result).to be_an(Array)
      expect(result.length).to eq 2

      first_segment = result[0]
      expect(first_segment["id"]).to eq 0
      expect(first_segment["text"]).to eq "Hello"
      expect(first_segment["confidence"]).to eq 0.95
      expect(first_segment["start"]).to eq 0.0
      expect(first_segment["end"]).to eq 2.5
    end

    it "calculates start times correctly" do
      result = transcribe.send(:build_segments, segments)

      expect(result[0]["start"]).to eq 0.0  # First segment starts at 0
      expect(result[1]["start"]).to eq 2.5  # Second segment starts at previous end
    end
  end

  describe "#calculate_segment_start" do
    subject(:transcribe) { described_class.new("test.mp3", client:, model: "latest_long") }

    let(:segments) do
      [
        { "resultEndOffset" => "2.5s" },
        { "resultEndOffset" => "5.0s" },
      ]
    end

    it "returns 0.0 for first segment" do
      result = transcribe.send(:calculate_segment_start, segments, 0)
      expect(result).to eq 0.0
    end

    it "returns previous segment end for subsequent segments" do
      result = transcribe.send(:calculate_segment_start, segments, 1)
      expect(result).to eq 2.5
    end
  end

  describe "#build_transcript_data" do
    subject(:transcribe) { described_class.new("test.mp3", client:, model: "latest_long", format: "json") }

    let(:segments) do
      [
        {
          "alternatives" => [{ "transcript" => "Hello" }],
          "resultEndOffset" => "2.0s",
        },
        {
          "alternatives" => [{ "transcript" => "world" }],
          "resultEndOffset" => "4.0s",
        },
      ]
    end

    let(:file_result) do
      {
        "metadata" => { "totalBilledDuration" => "4.0s" },
      }
    end

    it "builds transcript data with text and duration" do
      result = transcribe.send(:build_transcript_data, segments, file_result)
      expect(result["text"]).to eq "Hello world"
      expect(result["duration"]).to eq 4.0
    end
  end

  describe "#extract_transcript_text" do
    subject(:transcribe) { described_class.new("test.mp3", client:, model: "latest_long") }

    let(:segments) do
      [
        { "alternatives" => [{ "transcript" => "Hello" }] },
        { "alternatives" => [{ "transcript" => "world" }] },
        { "alternatives" => [] }, # Empty alternatives
        { "alternatives" => [{ "transcript" => "test" }] },
      ]
    end

    it "extracts and joins transcript text" do
      result = transcribe.send(:extract_transcript_text, segments)
      expect(result).to eq "Hello world test"
    end
  end

  describe "#add_duration_if_available" do
    subject(:transcribe) { described_class.new("test.mp3", client:, model: "latest_long") }

    it "adds duration when available" do
      result_data = {}
      file_result = { "metadata" => { "totalBilledDuration" => "10.5s" } }

      transcribe.send(:add_duration_if_available, result_data, file_result)
      expect(result_data["duration"]).to eq 10.5
    end

    it "does nothing when duration not available" do
      result_data = {}
      file_result = { "metadata" => {} }

      transcribe.send(:add_duration_if_available, result_data, file_result)
      expect(result_data["duration"]).to be_nil
    end
  end

  describe "#add_segments_if_verbose" do
    subject(:transcribe) { described_class.new("test.mp3", client:, model: "latest_long", format:) }

    let(:segments) do
      [{ "alternatives" => [{ "transcript" => "test" }], "resultEndOffset" => "1.0s" }]
    end

    context "with verbose_json format" do
      let(:format) { "verbose_json" }

      it "adds segments to result data" do
        result_data = {}
        transcribe.send(:add_segments_if_verbose, result_data, segments)
        expect(result_data["segments"]).to be_an(Array)
      end
    end

    context "with json format" do
      let(:format) { "json" }

      it "does not add segments" do
        result_data = {}
        transcribe.send(:add_segments_if_verbose, result_data, segments)
        expect(result_data["segments"]).to be_nil
      end
    end
  end

  describe "#empty_transcript_data" do
    subject(:transcribe) { described_class.new("test.mp3", client:, model: "latest_short") }

    it "returns hash with empty text" do
      result = transcribe.send(:empty_transcript_data)
      expect(result).to eq({ "text" => "" })
    end
  end
end
