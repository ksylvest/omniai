# frozen_string_literal: true

class Calculator < OmniAI::Tool
  description "Either add or subtract a set of values."

  parameter :values, :array, description: "A set of values.", items: OmniAI::Tool::Property.integer
  parameter :operation, :string, enum: %w[+ -], description: "The operation to perform."
  required %i[values operation]

  # @param values [Array<Integer>]
  # @param operation [String] "+" or "-"
  def execute(values:, operation:)
    case operation
    when "+" then values.reduce(:+)
    when "-" then values.reduce(:-)
    end
  end
end

RSpec.describe OmniAI::Tool do
  context "with a class" do
    subject(:tool) { Calculator.new }

    describe "#serialize" do
      it "converts the tool to a hash" do
        expect(tool.serialize).to eq({
          type: "function",
          function: {
            name: "calculator",
            description: "Either add or subtract a set of values.",
            parameters: {
              type: "object",
              properties: {
                values: {
                  type: "array",
                  description: "A set of values.",
                  items: { type: "integer" },
                },
                operation: {
                  type: "string",
                  enum: %w[+ -],
                  description: "The operation to perform.",
                },
              },
              required: %i[values operation],
            },
          },
        })
      end
    end

    describe "#call" do
      it "calls the proc" do
        expect(tool.call({ "values" => [5, 3], "operation" => "+" })).to eq(8)
        expect(tool.call({ "values" => [5, 3], "operation" => "-" })).to eq(2)
      end
    end
  end

  context "with a proc" do
    subject(:tool) { described_class.new(fibonacci, name:, description:, parameters:) }

    let(:fibonacci) do
      proc do |n:|
        next(0) if n == 0
        next(1) if n == 1

        fibonacci.call(n: n - 1) + fibonacci.call(n: n - 2)
      end
    end

    let(:name) { "Fibonacci" }
    let(:description) { "Calculate the nth Fibonacci" }

    let(:parameters) do
      OmniAI::Tool::Parameters.new(properties: {
        n: OmniAI::Tool::Property.integer(description: "The nth Fibonacci number to calculate"),
      }, required: %i[n])
    end

    describe "#serialize" do
      it "converts the tool to a hash" do
        expect(tool.serialize).to eq({
          type: "function",
          function: {
            name:,
            description:,
            parameters: {
              type: "object",
              properties: {
                n: { type: "integer", description: "The nth Fibonacci number to calculate" },
              },
              required: %i[n],
            },
          },
        })
      end
    end

    describe "#call" do
      it "calls the proc" do
        expect(tool.call({ "n" => 0 })).to eq(0)
        expect(tool.call({ "n" => 1 })).to eq(1)
        expect(tool.call({ "n" => 2 })).to eq(1)
        expect(tool.call({ "n" => 3 })).to eq(2)
        expect(tool.call({ "n" => 4 })).to eq(3)
        expect(tool.call({ "n" => 5 })).to eq(5)
        expect(tool.call({ "n" => 6 })).to eq(8)
      end
    end
  end
end
