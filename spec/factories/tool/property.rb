# frozen_string_literal: true

FactoryBot.define do
  factory :tool_property, class: "OmniAI::Tool::Property" do
    initialize_with { new(**attributes) }

    trait :integer do
      type { OmniAI::Tool::Property::Type::INTEGER }
    end

    trait :string do
      type { OmniAI::Tool::Property::Type::STRING }
    end

    trait :boolean do
      type { OmniAI::Tool::Property::Type::BOOLEAN }
    end

    trait :number do
      type { OmniAI::Tool::Property::Type::NUMBER }
    end
  end
end
