# frozen_string_literal: true

FactoryBot.define do
  factory :chat_prompt, class: "OmniAI::Chat::Prompt" do
    initialize_with { new(**attributes) }

    messages { [] }
  end
end
