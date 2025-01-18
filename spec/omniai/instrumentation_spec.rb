# frozen_string_literal: true

RSpec.describe OmniAI::Instrumentation do
  subject(:instrumentation) { described_class.new(logger:) }

  let(:logger) { instance_double(Logger) }

  let(:response) { instance_double(HTTP::Response, request:, status:) }
  let(:request) { instance_double(HTTP::Request, uri: "/chat", verb: "POST") }
  let(:status) { instance_double(HTTP::Response::Status, code: 200, reason: "OK") }

  describe "#instrument" do
    subject(:instrument) { instrumentation.instrument("Error", error: StandardError.new("unknown")) }

    context "with an error" do
      it "logs the error" do
        allow(logger).to receive(:error)
        instrument
        expect(logger).to have_received(:error).with("Error: unknown")
      end
    end
  end

  describe "#start" do
    subject(:start) { instrumentation.start("start", request:) }

    it "logs the request" do
      allow(logger).to receive(:info)
      start
      expect(logger).to have_received(:info).with("POST /chat")
    end
  end

  describe "#finish" do
    subject(:finish) { instrumentation.finish("finish", response:) }

    it "logs the response" do
      allow(logger).to receive(:info)
      finish
      expect(logger).to have_received(:info).with("200 OK")
    end
  end
end
