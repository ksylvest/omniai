# frozen_string_literal: true

FactoryBot.define do
  factory :schema_scalar, class: "OmniAI::Schema::Scalar" do
    initialize_with { new(**attributes) }

    trait :integer do
      type { OmniAI::Schema::Scalar::Type::INTEGER }
    end

    trait :string do
      type { OmniAI::Schema::Scalar::Type::STRING }
    end

    trait :boolean do
      type { OmniAI::Schema::Scalar::Type::BOOLEAN }
    end

    trait :number do
      type { OmniAI::Schema::Scalar::Type::NUMBER }
    end
  end
end
