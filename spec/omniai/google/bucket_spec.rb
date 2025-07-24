# frozen_string_literal: true

require "tempfile"

RSpec.describe OmniAI::Google::Bucket do
  let(:client) { OmniAI::Google::Client.new(api_key: "fake", project_id: "test-project", location_id: "us") }
  let(:large_audio_file) { StringIO.new("a" * 15_000_000) } # 15MB file
  let(:storage_client) { double("storage_client") } # rubocop:disable RSpec/VerifiedDoubles
  let(:bucket) { double("bucket") } # rubocop:disable RSpec/VerifiedDoubles
  let(:file) { double("file") } # rubocop:disable RSpec/VerifiedDoubles

  describe ".process!" do
    subject(:gcs_uri) { described_class.process!(client:, io: large_audio_file) }

    before do
      allow(Google::Cloud::Storage).to receive(:new).and_return(storage_client)
      allow(storage_client).to receive(:bucket).and_return(bucket)
      allow(bucket).to receive(:create_file).and_return(file)

      # Allow time mocking for filename generation
      allow(Time).to receive(:now).and_return(Time.new(2023, 1, 1, 12, 0, 0))
      allow(SecureRandom).to receive(:hex).with(4).and_return("abcd")
    end

    it "returns a GCS URI" do
      expect(gcs_uri).to match(%r{^gs://test-project-speech-audio/audio_\d{8}_\d{6}_[a-f0-9]{4}\.wav$})
    end

    context "with custom bucket name" do
      subject(:gcs_uri) { described_class.process!(client:, io: large_audio_file, bucket_name: "custom-bucket") }

      it "uses custom bucket name" do
        expect(gcs_uri).to start_with("gs://custom-bucket/")
      end
    end
  end

  describe "#initialize" do
    subject(:bucket_instance) { described_class.new(client:, io: large_audio_file) }

    it "sets instance variables correctly" do
      expect(bucket_instance.instance_variable_get(:@client)).to eq client
      expect(bucket_instance.instance_variable_get(:@io)).to eq large_audio_file
      expect(bucket_instance.instance_variable_get(:@bucket_name)).to eq "test-project-speech-audio"
    end

    context "with custom bucket name" do
      subject(:bucket_instance) { described_class.new(client:, io: large_audio_file, bucket_name: "custom-bucket") }

      it "uses custom bucket name" do
        expect(bucket_instance.instance_variable_get(:@bucket_name)).to eq "custom-bucket"
      end
    end
  end

  describe "#process!" do
    subject(:bucket_instance) { described_class.new(client:, io: test_io) }

    let(:test_io) { large_audio_file }

    before do
      allow(Google::Cloud::Storage).to receive(:new).and_return(storage_client)
      allow(storage_client).to receive(:bucket).and_return(bucket)
      allow(bucket).to receive(:create_file).and_return(file)
      allow(Time).to receive(:now).and_return(Time.new(2023, 1, 1, 12, 0, 0))
      allow(SecureRandom).to receive(:hex).with(4).and_return("abcd")
    end

    it "creates storage client with correct credentials" do
      bucket_instance.process!
      expect(Google::Cloud::Storage).to have_received(:new).with(
        project_id: "test-project",
        credentials: nil
      )
    end

    it "uploads file with generated filename" do
      result = bucket_instance.process!
      expect(result).to eq "gs://test-project-speech-audio/audio_20230101_120000_abcd.wav"
    end

    context "when bucket does not exist" do
      before do
        allow(storage_client).to receive(:bucket).and_return(nil)
      end

      it "raises UploadError" do
        expect { bucket_instance.process! }.to raise_error(
          OmniAI::Google::Bucket::UploadError,
          /Bucket 'test-project-speech-audio' not found/
        )
      end
    end

    context "when Google Cloud Storage raises an error" do
      before do
        allow(bucket).to receive(:create_file).and_raise(Google::Cloud::Error.new("Storage error"))
      end

      it "raises UploadError with wrapped message" do
        expect { bucket_instance.process! }.to raise_error(
          OmniAI::Google::Bucket::UploadError,
          /Failed to upload to GCS: Storage error/
        )
      end
    end

    context "with binary content" do
      let(:test_io) { StringIO.new("\\x00\\x01\\x02binary content") }

      it "handles binary content correctly" do
        result = bucket_instance.process!
        expect(result).to match(%r{^gs://test-project-speech-audio/audio_\d{8}_\d{6}_[a-f0-9]{4}\.wav$})
      end
    end

    context "with file path input" do
      let(:test_io) { "/path/to/audio.mp3" }

      before do
        allow(File).to receive(:exist?).with("/path/to/audio.mp3").and_return(true)
        allow(File).to receive(:read).with("/path/to/audio.mp3").and_return("file content")
      end

      it "uses mp3 extension" do
        result = bucket_instance.process!
        expect(result).to match(/\.mp3$/)
      end
    end
  end

  describe "private methods" do
    subject(:bucket_instance) { described_class.new(client:, io: large_audio_file) }

    describe "#project_id" do
      it "returns client project_id" do
        expect(bucket_instance.send(:project_id)).to eq "test-project"
      end
    end

    describe "#project_id when nil" do
      subject(:bucket_instance) { described_class.new(client:, io: large_audio_file) }

      let(:client) { OmniAI::Google::Client.new(api_key: "fake") }

      it "raises ArgumentError" do
        expect { bucket_instance.send(:project_id) }.to raise_error(
          ArgumentError,
          "project_id is required for GCS upload"
        )
      end
    end

    describe "#location_id" do
      it "returns client location_id" do
        expect(bucket_instance.send(:location_id)).to eq "us"
      end
    end

    describe "#location_id when nil" do
      subject(:bucket_instance) { described_class.new(client:, io: large_audio_file) }

      let(:client) { OmniAI::Google::Client.new(api_key: "fake", project_id: "test-project") }

      it "defaults to global" do
        expect(bucket_instance.send(:location_id)).to eq "global"
      end
    end

    describe "#default_bucket_name" do
      it "combines project_id with suffix" do
        expect(bucket_instance.send(:default_bucket_name)).to eq "test-project-speech-audio"
      end
    end

    describe "#file_content" do
      it "reads file path when file exists" do
        bucket_instance = described_class.new(client:, io: "/path/to/file.mp3")
        allow(File).to receive(:exist?).with("/path/to/file.mp3").and_return(true)
        allow(File).to receive(:read).with("/path/to/file.mp3").and_return("file content")
        expect(bucket_instance.send(:file_content)).to eq "file content"
      end

      it "returns string as binary when file does not exist" do
        bucket_instance = described_class.new(client:, io: "/path/to/file.mp3")
        allow(File).to receive(:exist?).with("/path/to/file.mp3").and_return(false)
        expect(bucket_instance.send(:file_content)).to eq "/path/to/file.mp3"
      end

      it "returns binary content as-is" do
        binary_content = "\\x00\\x01\\x02binary"
        bucket_instance = described_class.new(client:, io: binary_content)
        expect(bucket_instance.send(:file_content)).to eq binary_content
      end

      it "rewinds and reads IO object" do
        io_obj = StringIO.new("io content")
        bucket_instance = described_class.new(client:, io: io_obj)
        expect(bucket_instance.send(:file_content)).to eq "io content"
      end

      it "rewinds and reads StringIO object" do
        string_io = StringIO.new("string io content")
        bucket_instance = described_class.new(client:, io: string_io)
        expect(bucket_instance.send(:file_content)).to eq "string io content"
      end

      it "raises error for unsupported input type" do
        bucket_instance = described_class.new(client:, io: 12_345)
        expect { bucket_instance.send(:file_content) }.to raise_error(
          ArgumentError,
          "Unsupported input type: Integer"
        )
      end
    end

    describe "#file_extension" do
      it "extracts extension from file path" do
        bucket_instance = described_class.new(client:, io: "/path/to/file.mp3")
        expect(bucket_instance.send(:file_extension)).to eq "mp3"
      end

      it "defaults to wav for path without extension" do
        bucket_instance = described_class.new(client:, io: "/path/to/file")
        expect(bucket_instance.send(:file_extension)).to eq "wav"
      end

      it "defaults to wav for non-string input" do
        bucket_instance = described_class.new(client:, io: StringIO.new("content"))
        expect(bucket_instance.send(:file_extension)).to eq "wav"
      end
    end
  end

  describe "#needs_gcs_upload?" do
    let(:transcriber) { OmniAI::Google::Transcribe.new(test_file, client:, model: "latest_short") }

    context "with small file" do
      let(:test_file) { StringIO.new("small content") }

      it "returns false" do
        expect(transcriber.send(:needs_gcs_upload?)).to be false
      end
    end

    context "with large file" do
      let(:test_file) { StringIO.new("a" * 15_000_000) } # 15MB

      it "returns true" do
        expect(transcriber.send(:needs_gcs_upload?)).to be true
      end
    end

    context "with GCS URI" do
      let(:test_file) { "gs://existing-bucket/file.wav" }

      it "returns false" do
        expect(transcriber.send(:needs_gcs_upload?)).to be false
      end
    end
  end
end
