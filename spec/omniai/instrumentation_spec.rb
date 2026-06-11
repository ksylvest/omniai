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

    context "with a block (http 6 around_request contract)" do
      it "yields and returns the block's result so the response propagates" do
        allow(logger).to receive(:info)
        result = instrumentation.instrument("request.http", request:) { response }
        expect(result).to eq(response)
      end

      it "logs the response for the request event" do
        allow(logger).to receive(:info)
        instrumentation.instrument("request.http", request:) { response }
        expect(logger).to have_received(:info).with("200 OK")
      end

      it "logs the request for the start event and still yields" do
        allow(logger).to receive(:info)
        yielded = false
        instrumentation.instrument("start_request.http", request:) { yielded = true }
        expect(logger).to have_received(:info).with("POST /chat")
        expect(yielded).to be(true)
      end

      it "is benign for an error event with an empty block (http 6 on_error)" do
        allow(logger).to receive(:info)
        allow(logger).to receive(:error)
        result = instrumentation.instrument("error.http", request:, error: StandardError.new("boom")) { nil }
        expect(result).to be_nil
        expect(logger).to have_received(:error).with("error.http: boom")
        expect(logger).not_to have_received(:info)
      end
    end

    context "when plugged into http's real instrumentation feature" do
      let(:feature) { HTTP::Features::Instrumentation.new(instrumenter: instrumentation) }

      it "drives around_request and returns the response (reproduces the http 6 nil bug)" do
        skip "around_request is http 6+" unless feature.respond_to?(:around_request)
        allow(logger).to receive(:info)
        result = feature.around_request(request) { response }
        expect(result).to eq(response)
      end

      # Contract guard: drives http's REAL event names (not our own strings) so a
      # future upstream rename of the "start_" prefix fails loudly instead of
      # silently dropping the request log line.
      it "logs the request line via http's real event names" do
        skip "around_request is http 6+" unless feature.respond_to?(:around_request)
        allow(logger).to receive(:info)
        feature.around_request(request) { response }
        expect(logger).to have_received(:info).with("POST /chat")
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
