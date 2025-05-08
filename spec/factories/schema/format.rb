# frozen_string_literal: true

FactoryBot.define do
  factory :schema_format, class: "OmniAI::Schema::Format" do
    initialize_with { new(**attributes) }

    name { "example" }
    association(:schema, factory: :schema_object, strategy: :build)
  end
end
