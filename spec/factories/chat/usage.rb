# frozen_string_literal: true

FactoryBot.define do
  factory :chat_usage, class: "OmniAI::Chat::Usage" do
    initialize_with { new(**attributes) }

    input_tokens { 2 }
    output_tokens { 3 }
    total_tokens { input_tokens + output_tokens }
  end
end
