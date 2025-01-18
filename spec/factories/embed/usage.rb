# frozen_string_literal: true

FactoryBot.define do
  factory :embed_usage, class: "OmniAI::Embed::Usage" do
    initialize_with { new(**attributes) }

    prompt_tokens { 2 }
    total_tokens { 4 }
  end
end
