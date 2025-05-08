# frozen_string_literal: true

FactoryBot.define do
  factory :schema_array, class: "OmniAI::Schema::Array" do
    initialize_with { new(**attributes) }

    association(:items, factory: :schema_object, strategy: :build)
    min_items { 2 }
    max_items { 3 }
  end
end
