# frozen_string_literal: true

FactoryBot.define do
  factory :chat_function, class: "OmniAI::Chat::Function" do
    initialize_with { new(**attributes) }

    name { "temperature" }
    arguments { JSON.generate(unit: "celsius") }
  end
end
