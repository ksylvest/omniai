# frozen_string_literal: true

FactoryBot.define do
  factory :client, class: "OmniAI::Client" do
    initialize_with { new(**attributes) }

    host { "http://localhost:8080" }
    timeout { 5 }
    logger { Logger.new(File::NULL) }
  end
end
