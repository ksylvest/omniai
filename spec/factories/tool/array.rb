# frozen_string_literal: true

FactoryBot.define do
  factory :tool_array, class: "OmniAI::Tool::Array" do
    initialize_with { new(**attributes) }

    association(:items, factory: :tool_object, strategy: :build)
    min_items { 2 }
    max_items { 3 }
  end
end
