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
      OmniAI::Schema.object(properties: { location: OmniAI::Schema.string }, required: %i[location])
    end
  end
end
