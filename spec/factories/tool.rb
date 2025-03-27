# frozen_string_literal: true

FactoryBot.define do
  factory :tool, class: "OmniAI::Tool" do
    initialize_with { new(function, name:, description:, parameters:) }

    function do
      proc do |location:|
        case location
        when "London" then "Rainy"
        when "Madrid" then "Sunny"
        else raise ArgumentError, "unknown location=#{location}"
        end
      end
    end

    name { "weather" }
    description { "Finds the weather for a location." }

    parameters do
      OmniAI::Tool::Parameters.new(properties: { location: OmniAI::Tool::Property.string }, required: ["location"])
    end
  end
end
