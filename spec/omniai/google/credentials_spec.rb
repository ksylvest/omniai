# frozen_string_literal: true

RSpec.describe OmniAI::Google::Credentials do
  describe ".parse" do
    subject(:parse) { described_class.parse(value) }

    let(:config) do
      {
        type: "service_account",
        project_id: "fake",
        private_key_id: "fake",
        private_key: String(OpenSSL::PKey::RSA.new(2048)),
        client_email: "fake@fake.iam.gserviceaccount.com",
        client_id: "fake",
        auth_uri: "https://accounts.google.com/o/oauth2/auth",
        token_uri: "https://oauth2.googleapis.com/token",
        auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
        client_x509_cert_url: "https://www.googleapis.com/robot/v1/metadata/x509/fake.iam.gserviceaccount.com",
        universe_domain: "googleapis.com",
      }
    end

    let(:file) do
      tempfile = Tempfile.new(%w[credentials json])
      tempfile.write(JSON.generate(config))
      tempfile.flush
      tempfile
    end

    around do |example|
      example.run
    ensure
      file.close
      file.unlink
    end

    context "when value is a path" do
      let(:value) { Pathname(file.path) }

      it "parses to a 'Google::Auth::ServiceAccountCredentials'" do
        expect(parse).to be_a(Google::Auth::ServiceAccountCredentials)
      end
    end

    context "when value is a file" do
      let(:value) { File.open(file.path) }

      it "parses to a 'Google::Auth::ServiceAccountCredentials'" do
        expect(parse).to be_a(Google::Auth::ServiceAccountCredentials)
      end
    end

    context "when value is a hash" do
      let(:value) { config }

      it "parses to a 'Google::Auth::ServiceAccountCredentials'" do
        expect(parse).to be_a(Google::Auth::ServiceAccountCredentials)
      end
    end

    context "when value is a string" do
      let(:value) { JSON.generate(config) }

      it "parses to a 'Google::Auth::ServiceAccountCredentials'" do
        expect(parse).to be_a(Google::Auth::ServiceAccountCredentials)
      end
    end

    context "when value is a Google::Auth::ServiceAccountCredentials" do
      let(:value) do
        Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: File.open(file.path),
          scope: OmniAI::Google::Credentials::SCOPE
        )
      end

      it "returns the credentials" do
        expect(parse).to eql(value)
      end
    end
  end
end
