# frozen_string_literal: true

FactoryBot.define do
  factory :chat_choice, class: "OmniAI::Chat::Choice" do
    initialize_with { new(**attributes) }

    message factory: :chat_message
    index { 0 }
  end
end
