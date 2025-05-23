# frozen_string_literal: true

FactoryBot.define do
  factory :client, class: "OmniAI::Client" do
    initialize_with { new(**attributes) }

    api_key { "fake-api-key" }
    host { "http://localhost:8080" }
  end
end
